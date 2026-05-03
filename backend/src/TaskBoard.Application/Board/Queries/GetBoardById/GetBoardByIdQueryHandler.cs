using MediatR;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Board.DTOs;
using TaskBoard.Application.Columns.DTOs;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Application.TaskCards.DTOs;

namespace TaskBoard.Application.Board.Queries.GetBoardById;

/// <summary>Handles <see cref="GetBoardByIdQuery"/>: fetches board with columns and cards.</summary>
public sealed class GetBoardByIdQueryHandler : IRequestHandler<GetBoardByIdQuery, BoardDetailDto?>
{
    private readonly IApplicationDbContext _db;

    /// <summary>Initializes the handler.</summary>
    public GetBoardByIdQueryHandler(IApplicationDbContext db) => _db = db;

    /// <inheritdoc />
    public async Task<BoardDetailDto?> Handle(
        GetBoardByIdQuery request,
        CancellationToken cancellationToken)
    {
        var board = await _db.Boards
            .Where(b => b.Id == request.BoardId
                     && (b.OwnerId == request.UserId
                         || b.Members.Any(m => m.UserId == request.UserId)))
            .Select(b => new
            {
                b.Id, b.Name, b.OwnerId,
                OwnerName = b.Owner.Name,
                Columns = b.Columns
                    .OrderBy(c => c.Order)
                    .Select(c => new
                    {
                        c.Id, c.BoardId, c.Title, c.Order,
                        Cards = c.Cards
                            .OrderBy(t => t.Order)
                            .Select(t => new
                            {
                                t.Id, t.ColumnId, t.Title, t.Description,
                                t.AssigneeId,
                                AssigneeName = t.Assignee != null ? t.Assignee.Name : null,
                                Priority = t.Priority.ToString(),
                                t.DueDate, t.Order,
                                CommentCount = t.Comments.Count
                            })
                            .ToList()
                    })
                    .ToList()
            })
            .FirstOrDefaultAsync(cancellationToken);

        if (board is null) return null;

        return new BoardDetailDto(
            board.Id,
            board.Name,
            board.OwnerId,
            board.OwnerName,
            board.Columns.Select(c => new ColumnDto(
                c.Id,
                c.BoardId,
                c.Title,
                c.Order,
                c.Cards.Select(t => new TaskCardDto(
                    t.Id, t.ColumnId, t.Title, t.Description,
                    t.AssigneeId, t.AssigneeName,
                    t.Priority, t.DueDate, t.Order, t.CommentCount
                )).ToList()
            )).ToList());
    }
}
