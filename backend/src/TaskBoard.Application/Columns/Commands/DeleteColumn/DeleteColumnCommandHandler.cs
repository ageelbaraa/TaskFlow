using MediatR;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Application.Common.Models;

namespace TaskBoard.Application.Columns.Commands.DeleteColumn;

/// <summary>Handles <see cref="DeleteColumnCommand"/>.</summary>
public sealed class DeleteColumnCommandHandler : IRequestHandler<DeleteColumnCommand, Result<bool>>
{
    private readonly IApplicationDbContext _db;

    /// <summary>Initializes the handler.</summary>
    public DeleteColumnCommandHandler(IApplicationDbContext db) => _db = db;

    /// <inheritdoc />
    public async Task<Result<bool>> Handle(
        DeleteColumnCommand request,
        CancellationToken cancellationToken)
    {
        var column = await _db.Columns
            .Include(c => c.Board)
            .FirstOrDefaultAsync(c => c.Id == request.ColumnId, cancellationToken);

        if (column is null) return Result<bool>.Failure("Column not found.");
        if (column.Board.OwnerId != request.UserId)
            return Result<bool>.Failure("Only the board owner can delete columns.");

        _db.Columns.Remove(column);
        await _db.SaveChangesAsync(cancellationToken);

        return Result<bool>.Success(true);
    }
}
