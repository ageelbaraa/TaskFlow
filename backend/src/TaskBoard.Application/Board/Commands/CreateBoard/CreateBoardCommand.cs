using MediatR;
using TaskBoard.Application.Board.DTOs;
using TaskBoard.Application.Common.Models;

namespace TaskBoard.Application.Board.Commands.CreateBoard;

/// <summary>Creates a new board owned by the requesting user.</summary>
/// <param name="Name">Display name for the new board.</param>
/// <param name="UserId">The authenticated owner's identifier.</param>
public sealed record CreateBoardCommand(string Name, Guid UserId)
    : IRequest<Result<BoardDto>>;
