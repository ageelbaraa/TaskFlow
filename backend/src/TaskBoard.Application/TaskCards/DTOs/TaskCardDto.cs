namespace TaskBoard.Application.TaskCards.DTOs;

/// <summary>Task card representation safe for client consumption.</summary>
/// <param name="Id">Card identifier.</param>
/// <param name="ColumnId">Column this card currently belongs to.</param>
/// <param name="Title">Short card title.</param>
/// <param name="Description">Optional long-form description.</param>
/// <param name="AssigneeId">Optional identifier of the assigned user.</param>
/// <param name="AssigneeName">Display name of the assigned user, or null.</param>
/// <param name="Priority">Priority label string.</param>
/// <param name="DueDate">Optional UTC due date.</param>
/// <param name="Order">Zero-based display order within the column.</param>
/// <param name="CommentCount">Number of comments on this card.</param>
public sealed record TaskCardDto(
    Guid Id,
    Guid ColumnId,
    string Title,
    string? Description,
    Guid? AssigneeId,
    string? AssigneeName,
    string Priority,
    DateTime? DueDate,
    int Order,
    int CommentCount);
