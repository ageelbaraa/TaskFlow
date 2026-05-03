using MediatR;
using TaskBoard.Application.Common.Models;
using TaskBoard.Application.TaskCards.DTOs;
using TaskBoard.Domain.Enums;

namespace TaskBoard.Application.TaskCards.Commands.CreateTaskCard;

/// <summary>Creates a new task card appended to the bottom of the specified column.</summary>
/// <param name="ColumnId">Target column identifier.</param>
/// <param name="Title">Card title.</param>
/// <param name="Description">Optional card description.</param>
/// <param name="AssigneeId">Optional user to assign immediately.</param>
/// <param name="Priority">Initial priority level.</param>
/// <param name="DueDate">Optional UTC due date.</param>
/// <param name="UserId">Requesting user identifier.</param>
public sealed record CreateTaskCardCommand(
    Guid ColumnId,
    string Title,
    string? Description,
    Guid? AssigneeId,
    Priority Priority,
    DateTime? DueDate,
    Guid UserId) : IRequest<Result<TaskCardDto>>;
