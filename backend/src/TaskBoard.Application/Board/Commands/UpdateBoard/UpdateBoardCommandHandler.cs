using MediatR;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Board.DTOs;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Application.Common.Models;

namespace TaskBoard.Application.Board.Commands.UpdateBoard;

/// <summary>Handles <see cref="UpdateBoardCommand"/>.</summary>
public sealed class UpdateBoardCommandHandler
    : IRequestHandler<UpdateBoardCommand, Result<BoardDto>>
{
    private readonly IApplicationDbContext _db;

    /// <summary>Initializes the handler.</summary>
    public UpdateBoardCommandHandler(IApplicationDbContext db) => _db = db;

    /// <inheritdoc />
    public async Task<Result<BoardDto>> Handle(
        UpdateBoardCommand request,
        CancellationToken cancellationToken)
    {
        var board = await _db.Boards
            .Include(b => b.Owner)
            .Include(b => b.Columns)
            .Include(b => b.Members)
            .FirstOrDefaultAsync(b => b.Id == request.BoardId, cancellationToken);

        if (board is null) return Result<BoardDto>.Failure("Board not found.");
        if (board.OwnerId != request.UserId)
            return Result<BoardDto>.Failure("Only the board owner can rename the board.");

        board.Name = request.Name.Trim();
        await _db.SaveChangesAsync(cancellationToken);

        return Result<BoardDto>.Success(new BoardDto(
            board.Id, board.Name, board.OwnerId, board.Owner.Name,
            board.Columns.Count, board.Members.Count + 1, board.CreatedAt));
    }
}
