namespace TaskBoard.Application.Comments.DTOs;

/// <summary>
/// Comment representation safe for client consumption.
/// <see cref="BoardId"/> is included so API endpoints know which SignalR
/// group to broadcast to without an extra round-trip.
/// </summary>
/// <param name="Id">Comment identifier.</param>
/// <param name="TaskCardId">The card this comment belongs to.</param>
/// <param name="BoardId">The board the card lives on (for hub routing).</param>
/// <param name="AuthorId">Comment author's identifier.</param>
/// <param name="AuthorName">Comment author's display name.</param>
/// <param name="Body">Markdown body of the comment.</param>
/// <param name="CreatedAt">UTC timestamp of creation.</param>
public sealed record CommentDto(
    Guid Id,
    Guid TaskCardId,
    Guid BoardId,
    Guid AuthorId,
    string AuthorName,
    string Body,
    DateTime CreatedAt);
