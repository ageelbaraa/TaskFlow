using MediatR;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Board.DTOs;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Application.Common.Models;

namespace TaskBoard.Application.Board.Commands.CreateBoard;

/// <summary>Handles <see cref="CreateBoardCommand"/>.</summary>
public sealed class CreateBoardCommandHandler
    : IRequestHandler<CreateBoardCommand, Result<BoardDto>>
{
    private readonly IApplicationDbContext _db;

    /// <summary>Initializes the handler.</summary>
    public CreateBoardCommandHandler(IApplicationDbContext db) => _db = db;

    /// <inheritdoc />
    public async Task<Result<BoardDto>> Handle(
        CreateBoardCommand request,
        CancellationToken cancellationToken)
    {
        var owner = await _db.Users.FirstOrDefaultAsync(
            u => u.Id == request.UserId, cancellationToken);

        if (owner is null)
            return Result<BoardDto>.Failure("User not found.");

        var board = new Domain.Entities.BoardModel
        {
            Name = request.Name.Trim(),
            OwnerId = request.UserId
        };

        _db.Boards.Add(board);
        await _db.SaveChangesAsync(cancellationToken);

        return Result<BoardDto>.Success(
            new BoardDto(board.Id, board.Name, board.OwnerId, owner.Name, 0, 1, board.CreatedAt));
    }
}
