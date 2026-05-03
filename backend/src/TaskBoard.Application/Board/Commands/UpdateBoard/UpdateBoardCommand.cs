using MediatR;
using TaskBoard.Application.Board.DTOs;
using TaskBoard.Application.Common.Models;

namespace TaskBoard.Application.Board.Commands.UpdateBoard;

/// <summary>Renames a board. Only the owner may rename.</summary>
/// <param name="BoardId">Board to update.</param>
/// <param name="Name">New display name.</param>
/// <param name="UserId">Requesting user (must be owner).</param>
public sealed record UpdateBoardCommand(Guid BoardId, string Name, Guid UserId)
    : IRequest<Result<BoardDto>>;
