using MediatR;
using TaskBoard.Application.Common.Models;

namespace TaskBoard.Application.Board.Commands.DeleteBoard;

/// <summary>Deletes a board and all its contents. Only the owner may delete.</summary>
/// <param name="BoardId">Board to delete.</param>
/// <param name="UserId">Requesting user (must be owner).</param>
public sealed record DeleteBoardCommand(Guid BoardId, Guid UserId)
    : IRequest<Result<bool>>;
