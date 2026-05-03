using MediatR;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Application.Common.Models;

namespace TaskBoard.Application.Board.Commands.DeleteBoard;

/// <summary>Handles <see cref="DeleteBoardCommand"/>.</summary>
public sealed class DeleteBoardCommandHandler : IRequestHandler<DeleteBoardCommand, Result<bool>>
{
    private readonly IApplicationDbContext _db;

    /// <summary>Initializes the handler.</summary>
    public DeleteBoardCommandHandler(IApplicationDbContext db) => _db = db;

    /// <inheritdoc />
    public async Task<Result<bool>> Handle(
        DeleteBoardCommand request,
        CancellationToken cancellationToken)
    {
        var board = await _db.Boards
            .FirstOrDefaultAsync(b => b.Id == request.BoardId, cancellationToken);

        if (board is null) return Result<bool>.Failure("Board not found.");
        if (board.OwnerId != request.UserId)
            return Result<bool>.Failure("Only the board owner can delete the board.");

        _db.Boards.Remove(board);
        await _db.SaveChangesAsync(cancellationToken);

        return Result<bool>.Success(true);
    }
}
