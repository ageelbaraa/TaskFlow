using MediatR;
using TaskBoard.Application.Common.Models;

namespace TaskBoard.Application.Columns.Commands.DeleteColumn;

/// <summary>Deletes a column and all its task cards.</summary>
/// <param name="ColumnId">Column to delete.</param>
/// <param name="UserId">Requesting user (must be board owner).</param>
public sealed record DeleteColumnCommand(Guid ColumnId, Guid UserId)
    : IRequest<Result<bool>>;
