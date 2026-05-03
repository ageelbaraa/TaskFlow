using MediatR;
using TaskBoard.Application.Board.DTOs;

namespace TaskBoard.Application.Board.Queries.GetBoardById;

/// <summary>Returns the full board detail including columns and cards.</summary>
/// <param name="BoardId">The board to retrieve.</param>
/// <param name="UserId">The requesting user (used for access check).</param>
public sealed record GetBoardByIdQuery(Guid BoardId, Guid UserId) : IRequest<BoardDetailDto?>;
