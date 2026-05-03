using TaskBoard.Application.Common.DTOs;

namespace TaskBoard.Application.Common.Interfaces;

/// <summary>Tracks which users are currently online on a given board.</summary>
public interface IPresenceService
{
    /// <summary>Records that <paramref name="userId"/> joined <paramref name="boardId"/>.</summary>
    Task TrackJoinAsync(Guid boardId, Guid userId, string userName, CancellationToken ct = default);

    /// <summary>Removes <paramref name="userId"/> from the online set for <paramref name="boardId"/>.</summary>
    Task TrackLeaveAsync(Guid boardId, Guid userId, CancellationToken ct = default);

    /// <summary>Returns every user currently tracked as online for <paramref name="boardId"/>.</summary>
    Task<IReadOnlyList<OnlineUserDto>> GetOnlineUsersAsync(Guid boardId, CancellationToken ct = default);
}
