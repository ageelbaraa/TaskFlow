using MediatR;
using TaskBoard.Application.Common.Models;
using TaskBoard.Application.TaskCards.DTOs;
using TaskBoard.Domain.Enums;

namespace TaskBoard.Application.TaskCards.Commands.UpdateTaskCard;

/// <summary>Updates editable fields of an existing task card.</summary>
/// <param name="CardId">Card to update.</param>
/// <param name="Title">New title.</param>
/// <param name="Description">New description (null clears it).</param>
/// <param name="AssigneeId">New assignee (null unassigns).</param>
/// <param name="Priority">New priority.</param>
/// <param name="DueDate">New due date (null clears it).</param>
/// <param name="UserId">Requesting user.</param>
public sealed record UpdateTaskCardCommand(
    Guid CardId,
    string Title,
    string? Description,
    Guid? AssigneeId,
    Priority Priority,
    DateTime? DueDate,
    Guid UserId) : IRequest<Result<TaskCardDto>>;
