using StackExchange.Redis;
using TaskBoard.Application.Common.DTOs;
using TaskBoard.Application.Common.Interfaces;

namespace TaskBoard.Infrastructure.Services;

/// <summary>
/// Redis-backed presence service. Uses a hash per board:
/// key = <c>board:{boardId}:presence</c>, field = userId, value = userName.
/// A 2-hour TTL prevents stale entries surviving server restarts.
/// </summary>
public sealed class RedisPresenceService : IPresenceService
{
    private static readonly TimeSpan Ttl = TimeSpan.FromHours(2);
    private readonly IConnectionMultiplexer _redis;

    /// <summary>Initializes the service with a Redis connection multiplexer.</summary>
    public RedisPresenceService(IConnectionMultiplexer redis) => _redis = redis;

    /// <inheritdoc />
    public async Task TrackJoinAsync(Guid boardId, Guid userId, string userName,
        CancellationToken ct = default)
    {
        var db = _redis.GetDatabase();
        var key = BoardKey(boardId);
        await db.HashSetAsync(key, userId.ToString(), userName);
        await db.KeyExpireAsync(key, Ttl);
    }

    /// <inheritdoc />
    public async Task TrackLeaveAsync(Guid boardId, Guid userId,
        CancellationToken ct = default)
    {
        var db = _redis.GetDatabase();
        await db.HashDeleteAsync(BoardKey(boardId), userId.ToString());
    }

    /// <inheritdoc />
    public async Task<IReadOnlyList<OnlineUserDto>> GetOnlineUsersAsync(Guid boardId,
        CancellationToken ct = default)
    {
        var db = _redis.GetDatabase();
        var entries = await db.HashGetAllAsync(BoardKey(boardId));
        return entries
            .Where(e => e.Name.HasValue && e.Value.HasValue)
            .Select(e => new OnlineUserDto(Guid.Parse(e.Name!), e.Value!))
            .ToList();
    }

    private static string BoardKey(Guid boardId) => $"board:{boardId}:presence";
}
