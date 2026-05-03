using System.Collections.Concurrent;
using TaskBoard.Application.Common.DTOs;
using TaskBoard.Application.Common.Interfaces;

namespace TaskBoard.Infrastructure.Services;

/// <summary>
/// Thread-safe in-memory presence service used when Redis is not configured
/// (local development without a Redis container).
/// Data is not shared across multiple server instances.
/// </summary>
public sealed class InMemoryPresenceService : IPresenceService
{
    // boardId → (userId → userName)
    private readonly ConcurrentDictionary<Guid, ConcurrentDictionary<Guid, string>> _state = new();

    /// <inheritdoc />
    public Task TrackJoinAsync(Guid boardId, Guid userId, string userName,
        CancellationToken ct = default)
    {
        _state.GetOrAdd(boardId, _ => new ConcurrentDictionary<Guid, string>())
              .AddOrUpdate(userId, userName, (_, _) => userName);
        return Task.CompletedTask;
    }

    /// <inheritdoc />
    public Task TrackLeaveAsync(Guid boardId, Guid userId,
        CancellationToken ct = default)
    {
        if (_state.TryGetValue(boardId, out var board))
            board.TryRemove(userId, out _);
        return Task.CompletedTask;
    }

    /// <inheritdoc />
    public Task<IReadOnlyList<OnlineUserDto>> GetOnlineUsersAsync(Guid boardId,
        CancellationToken ct = default)
    {
        if (!_state.TryGetValue(boardId, out var board))
            return Task.FromResult<IReadOnlyList<OnlineUserDto>>(Array.Empty<OnlineUserDto>());

        IReadOnlyList<OnlineUserDto> result = board
            .Select(kvp => new OnlineUserDto(kvp.Key, kvp.Value))
            .ToList();

        return Task.FromResult(result);
    }
}
