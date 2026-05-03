using MediatR;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Application.Common.Models;
using TaskBoard.Application.TaskCards.DTOs;

namespace TaskBoard.Application.TaskCards.Commands.MoveCard;

/// <summary>Handles <see cref="MoveCardCommand"/>: moves card, reorders siblings in both columns.</summary>
public sealed class MoveCardCommandHandler : IRequestHandler<MoveCardCommand, Result<TaskCardDto>>
{
    private readonly IApplicationDbContext _db;

    /// <summary>Initializes the handler.</summary>
    public MoveCardCommandHandler(IApplicationDbContext db) => _db = db;

    /// <inheritdoc />
    public async Task<Result<TaskCardDto>> Handle(
        MoveCardCommand request,
        CancellationToken cancellationToken)
    {
        var card = await _db.TaskCards
            .Include(t => t.Column).ThenInclude(c => c.Board).ThenInclude(b => b.Members)
            .Include(t => t.Assignee)
            .Include(t => t.Comments)
            .FirstOrDefaultAsync(t => t.Id == request.CardId, cancellationToken);

        if (card is null) return Result<TaskCardDto>.Failure("Card not found.");

        var destColumn = await _db.Columns
            .FirstOrDefaultAsync(c => c.Id == request.ToColumnId, cancellationToken);

        if (destColumn is null) return Result<TaskCardDto>.Failure("Destination column not found.");
        if (destColumn.BoardId != card.Column.BoardId)
            return Result<TaskCardDto>.Failure("Destination column is on a different board.");

        bool canEdit = card.Column.Board.OwnerId == request.UserId
            || card.Column.Board.Members.Any(m => m.UserId == request.UserId);

        if (!canEdit) return Result<TaskCardDto>.Failure("Access denied.");

        var sourceColumnId = card.ColumnId;
        var newOrder = Math.Max(0, request.NewOrder);

        // Remove card from source column and compact remaining cards
        var sourceCards = await _db.TaskCards
            .Where(t => t.ColumnId == sourceColumnId && t.Id != card.Id)
            .OrderBy(t => t.Order)
            .ToListAsync(cancellationToken);

        for (int i = 0; i < sourceCards.Count; i++)
            sourceCards[i].Order = i;

        // Insert card into destination column at newOrder
        var destCards = await _db.TaskCards
            .Where(t => t.ColumnId == request.ToColumnId && t.Id != card.Id)
            .OrderBy(t => t.Order)
            .ToListAsync(cancellationToken);

        newOrder = Math.Min(newOrder, destCards.Count);

        card.ColumnId = request.ToColumnId;
        card.Order = newOrder;

        for (int i = 0; i < destCards.Count; i++)
            destCards[i].Order = i < newOrder ? i : i + 1;

        await _db.SaveChangesAsync(cancellationToken);

        return Result<TaskCardDto>.Success(new TaskCardDto(
            card.Id, card.ColumnId, card.Title, card.Description,
            card.AssigneeId, card.Assignee?.Name,
            card.Priority.ToString(), card.DueDate, card.Order, card.Comments.Count));
    }
}
