using MediatR;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Application.Common.Models;
using TaskBoard.Application.TaskCards.DTOs;

namespace TaskBoard.Application.TaskCards.Commands.UpdateTaskCard;

/// <summary>Handles <see cref="UpdateTaskCardCommand"/>.</summary>
public sealed class UpdateTaskCardCommandHandler
    : IRequestHandler<UpdateTaskCardCommand, Result<TaskCardDto>>
{
    private readonly IApplicationDbContext _db;

    /// <summary>Initializes the handler.</summary>
    public UpdateTaskCardCommandHandler(IApplicationDbContext db) => _db = db;

    /// <inheritdoc />
    public async Task<Result<TaskCardDto>> Handle(
        UpdateTaskCardCommand request,
        CancellationToken cancellationToken)
    {
        var card = await _db.TaskCards
            .Include(t => t.Column).ThenInclude(c => c.Board).ThenInclude(b => b.Members)
            .Include(t => t.Assignee)
            .Include(t => t.Comments)
            .FirstOrDefaultAsync(t => t.Id == request.CardId, cancellationToken);

        if (card is null) return Result<TaskCardDto>.Failure("Card not found.");

        bool canEdit = card.Column.Board.OwnerId == request.UserId
            || card.Column.Board.Members.Any(m => m.UserId == request.UserId);

        if (!canEdit) return Result<TaskCardDto>.Failure("Access denied.");

        card.Title = request.Title.Trim();
        card.Description = request.Description?.Trim();
        card.AssigneeId = request.AssigneeId;
        card.Priority = request.Priority;
        card.DueDate = request.DueDate;

        await _db.SaveChangesAsync(cancellationToken);

        string? assigneeName = request.AssigneeId.HasValue
            ? await _db.Users.Where(u => u.Id == request.AssigneeId.Value)
                              .Select(u => u.Name)
                              .FirstOrDefaultAsync(cancellationToken)
            : null;

        return Result<TaskCardDto>.Success(new TaskCardDto(
            card.Id, card.ColumnId, card.Title, card.Description,
            card.AssigneeId, assigneeName,
            card.Priority.ToString(), card.DueDate, card.Order, card.Comments.Count));
    }
}
