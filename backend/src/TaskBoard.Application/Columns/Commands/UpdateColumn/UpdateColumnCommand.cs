using MediatR;
using TaskBoard.Application.Columns.DTOs;
using TaskBoard.Application.Common.Models;

namespace TaskBoard.Application.Columns.Commands.UpdateColumn;

/// <summary>Renames a column.</summary>
/// <param name="ColumnId">Column to update.</param>
/// <param name="Title">New title.</param>
/// <param name="UserId">Requesting user.</param>
public sealed record UpdateColumnCommand(Guid ColumnId, string Title, Guid UserId)
    : IRequest<Result<ColumnDto>>;
