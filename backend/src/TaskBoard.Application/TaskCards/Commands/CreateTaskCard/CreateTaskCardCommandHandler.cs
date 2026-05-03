using MediatR;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Application.Common.Models;
using TaskBoard.Application.TaskCards.DTOs;
using TaskBoard.Domain.Entities;

namespace TaskBoard.Application.TaskCards.Commands.CreateTaskCard;

/// <summary>Handles <see cref="CreateTaskCardCommand"/>.</summary>
public sealed class CreateTaskCardCommandHandler
    : IRequestHandler<CreateTaskCardCommand, Result<TaskCardDto>>
{
    private readonly IApplicationDbContext _db;

    /// <summary>Initializes the handler.</summary>
    public CreateTaskCardCommandHandler(IApplicationDbContext db) => _db = db;

    /// <inheritdoc />
    public async Task<Result<TaskCardDto>> Handle(
        CreateTaskCardCommand request,
        CancellationToken cancellationToken)
    {
        var column = await _db.Columns
            .Include(c => c.Board).ThenInclude(b => b.Members)
            .FirstOrDefaultAsync(c => c.Id == request.ColumnId, cancellationToken);

        if (column is null) return Result<TaskCardDto>.Failure("Column not found.");

        bool canEdit = column.Board.OwnerId == request.UserId
            || column.Board.Members.Any(m => m.UserId == request.UserId);

        if (!canEdit) return Result<TaskCardDto>.Failure("Access denied.");

        int nextOrder = await _db.TaskCards
            .CountAsync(t => t.ColumnId == request.ColumnId, cancellationToken);

        string? assigneeName = null;
        if (request.AssigneeId.HasValue)
        {
            assigneeName = await _db.Users
                .Where(u => u.Id == request.AssigneeId.Value)
                .Select(u => u.Name)
                .FirstOrDefaultAsync(cancellationToken);
        }

        var card = new TaskCard
        {
            ColumnId = request.ColumnId,
            Title = request.Title.Trim(),
            Description = request.Description?.Trim(),
            AssigneeId = request.AssigneeId,
            Priority = request.Priority,
            DueDate = request.DueDate,
            Order = nextOrder
        };

        _db.TaskCards.Add(card);
        await _db.SaveChangesAsync(cancellationToken);

        return Result<TaskCardDto>.Success(new TaskCardDto(
            card.Id, card.ColumnId, card.Title, card.Description,
            card.AssigneeId, assigneeName,
            card.Priority.ToString(), card.DueDate, card.Order, 0));
    }
}
