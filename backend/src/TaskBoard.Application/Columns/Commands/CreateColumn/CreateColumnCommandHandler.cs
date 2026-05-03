using MediatR;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Columns.DTOs;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Application.Common.Models;
using TaskBoard.Domain.Enums;

namespace TaskBoard.Application.Columns.Commands.CreateColumn;

/// <summary>Handles <see cref="CreateColumnCommand"/>.</summary>
public sealed class CreateColumnCommandHandler
    : IRequestHandler<CreateColumnCommand, Result<ColumnDto>>
{
    private readonly IApplicationDbContext _db;

    /// <summary>Initializes the handler.</summary>
    public CreateColumnCommandHandler(IApplicationDbContext db) => _db = db;

    /// <inheritdoc />
    public async Task<Result<ColumnDto>> Handle(
        CreateColumnCommand request,
        CancellationToken cancellationToken)
    {
        var board = await _db.Boards
            .Include(b => b.Members)
            .FirstOrDefaultAsync(b => b.Id == request.BoardId, cancellationToken);

        if (board is null) return Result<ColumnDto>.Failure("Board not found.");

        bool canEdit = board.OwnerId == request.UserId
            || board.Members.Any(m => m.UserId == request.UserId
                                   && m.Role != UserRole.Viewer);

        if (!canEdit) return Result<ColumnDto>.Failure("You do not have permission to add columns.");

        int nextOrder = await _db.Columns
            .Where(c => c.BoardId == request.BoardId)
            .CountAsync(cancellationToken);

        var column = new Domain.Entities.Column
        {
            BoardId = request.BoardId,
            Title = request.Title.Trim(),
            Order = nextOrder
        };

        _db.Columns.Add(column);
        await _db.SaveChangesAsync(cancellationToken);

        return Result<ColumnDto>.Success(
            new ColumnDto(column.Id, column.BoardId, column.Title, column.Order, []));
    }
}
