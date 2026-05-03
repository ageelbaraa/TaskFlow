using MediatR;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Application.Common.Models;

namespace TaskBoard.Application.TaskCards.Commands.DeleteTaskCard;

/// <summary>Handles <see cref="DeleteTaskCardCommand"/>.</summary>
public sealed class DeleteTaskCardCommandHandler : IRequestHandler<DeleteTaskCardCommand, Result<bool>>
{
    private readonly IApplicationDbContext _db;

    /// <summary>Initializes the handler.</summary>
    public DeleteTaskCardCommandHandler(IApplicationDbContext db) => _db = db;

    /// <inheritdoc />
    public async Task<Result<bool>> Handle(
        DeleteTaskCardCommand request,
        CancellationToken cancellationToken)
    {
        var card = await _db.TaskCards
            .Include(t => t.Column).ThenInclude(c => c.Board).ThenInclude(b => b.Members)
            .FirstOrDefaultAsync(t => t.Id == request.CardId, cancellationToken);

        if (card is null) return Result<bool>.Failure("Card not found.");

        bool canEdit = card.Column.Board.OwnerId == request.UserId
            || card.Column.Board.Members.Any(m => m.UserId == request.UserId);

        if (!canEdit) return Result<bool>.Failure("Access denied.");

        _db.TaskCards.Remove(card);
        await _db.SaveChangesAsync(cancellationToken);

        return Result<bool>.Success(true);
    }
}
