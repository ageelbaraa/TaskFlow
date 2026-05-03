using MediatR;
using TaskBoard.Application.Columns.DTOs;
using TaskBoard.Application.Common.Models;

namespace TaskBoard.Application.Columns.Commands.CreateColumn;

/// <summary>Adds a new column to a board. Appended after the last existing column.</summary>
/// <param name="BoardId">Parent board identifier.</param>
/// <param name="Title">Column header title.</param>
/// <param name="UserId">Requesting user (must be owner or Member).</param>
public sealed record CreateColumnCommand(Guid BoardId, string Title, Guid UserId)
    : IRequest<Result<ColumnDto>>;
