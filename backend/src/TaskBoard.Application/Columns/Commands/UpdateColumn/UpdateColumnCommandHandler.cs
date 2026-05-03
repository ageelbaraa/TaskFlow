using MediatR;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Columns.DTOs;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Application.Common.Models;
using TaskBoard.Application.TaskCards.DTOs;

namespace TaskBoard.Application.Columns.Commands.UpdateColumn;

/// <summary>Handles <see cref="UpdateColumnCommand"/>.</summary>
public sealed class UpdateColumnCommandHandler
    : IRequestHandler<UpdateColumnCommand, Result<ColumnDto>>
{
    private readonly IApplicationDbContext _db;

    /// <summary>Initializes the handler.</summary>
    public UpdateColumnCommandHandler(IApplicationDbContext db) => _db = db;

    /// <inheritdoc />
    public async Task<Result<ColumnDto>> Handle(
        UpdateColumnCommand request,
        CancellationToken cancellationToken)
    {
        var column = await _db.Columns
            .Include(c => c.Board).ThenInclude(b => b.Members)
            .Include(c => c.Cards).ThenInclude(t => t.Assignee)
            .Include(c => c.Cards).ThenInclude(t => t.Comments)
            .FirstOrDefaultAsync(c => c.Id == request.ColumnId, cancellationToken);

        if (column is null) return Result<ColumnDto>.Failure("Column not found.");

        bool canEdit = column.Board.OwnerId == request.UserId
            || column.Board.Members.Any(m => m.UserId == request.UserId);

        if (!canEdit) return Result<ColumnDto>.Failure("Access denied.");

        column.Title = request.Title.Trim();
        await _db.SaveChangesAsync(cancellationToken);

        var cards = column.Cards
            .OrderBy(t => t.Order)
            .Select(t => new TaskCardDto(
                t.Id, t.ColumnId, t.Title, t.Description,
                t.AssigneeId, t.Assignee?.Name,
                t.Priority.ToString(), t.DueDate, t.Order, t.Comments.Count))
            .ToList();

        return Result<ColumnDto>.Success(
            new ColumnDto(column.Id, column.BoardId, column.Title, column.Order, cards));
    }
}
