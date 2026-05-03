using MediatR;
using TaskBoard.Application.Board.DTOs;

namespace TaskBoard.Application.Board.Queries.GetBoards;

/// <summary>Returns all boards the requesting user owns or is a member of.</summary>
/// <param name="UserId">The authenticated user's identifier (injected by the endpoint).</param>
public sealed record GetBoardsQuery(Guid UserId) : IRequest<IReadOnlyList<BoardDto>>;
