using TaskBoard.Application.TaskCards.DTOs;

namespace TaskBoard.API.Hubs;

/// <summary>
/// Strongly-typed interface describing every server→client event the BoardHub can push.
/// Using a typed hub eliminates string-based method name mismatches.
/// </summary>
public interface IBoardHubClient
{
    /// <summary>Broadcast when any client successfully moves a card.</summary>
    /// <param name="cardId">The card that was moved.</param>
    /// <param name="fromColumnId">The column the card left.</param>
    /// <param name="toColumnId">The column the card entered.</param>
    /// <param name="newOrder">Zero-based position in the destination column.</param>
    Task CardMoved(Guid cardId, Guid fromColumnId, Guid toColumnId, int newOrder);

    /// <summary>Broadcast when a card's metadata is updated.</summary>
    /// <param name="cardId">The updated card's identifier.</param>
    /// <param name="card">The full updated card DTO.</param>
    Task CardUpdated(Guid cardId, TaskCardDto card);

    /// <summary>Broadcast when a new comment is posted on a card.</summary>
    /// <param name="taskId">The card the comment belongs to.</param>
    /// <param name="comment">Serialized comment payload.</param>
    Task CommentAdded(Guid taskId, object comment);

    /// <summary>Broadcast when a user opens the board.</summary>
    Task UserJoined(Guid userId, string userName, Guid boardId);

    /// <summary>Broadcast when a user closes or loses connection to the board.</summary>
    Task UserLeft(Guid userId, Guid boardId);
}
