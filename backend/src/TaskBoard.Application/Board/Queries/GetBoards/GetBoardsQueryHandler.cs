using MediatR;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Board.DTOs;
using TaskBoard.Application.Common.Interfaces;

namespace TaskBoard.Application.Board.Queries.GetBoards;

/// <summary>Handles <see cref="GetBoardsQuery"/>: returns summary boards visible to the requesting user.</summary>
public sealed class GetBoardsQueryHandler : IRequestHandler<GetBoardsQuery, IReadOnlyList<BoardDto>>
{
    private readonly IApplicationDbContext _db;

    /// <summary>Initializes the handler.</summary>
    public GetBoardsQueryHandler(IApplicationDbContext db) => _db = db;

    /// <inheritdoc />
    public async Task<IReadOnlyList<BoardDto>> Handle(
        GetBoardsQuery request,
        CancellationToken cancellationToken)
    {
        return await _db.Boards
            .Where(b => b.OwnerId == request.UserId
                     || b.Members.Any(m => m.UserId == request.UserId))
            .Select(b => new BoardDto(
                b.Id,
                b.Name,
                b.OwnerId,
                b.Owner.Name,
                b.Columns.Count,
                b.Members.Count + 1,
                b.CreatedAt))
            .OrderByDescending(b => b.CreatedAt)
            .ToListAsync(cancellationToken);
    }
}
