using System.Security.Claims;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Common.DTOs;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Application.TaskCards.Commands.MoveCard;

namespace TaskBoard.API.Hubs;

/// <summary>
/// Real-time SignalR hub for a Kanban board.
/// Clients join a board group via <see cref="JoinBoard"/>.  All card-move,
/// comment, and presence events are broadcast to every member of that group.
/// </summary>
[Authorize]
public sealed class BoardHub : Hub<IBoardHubClient>
{
    private const string BoardIdKey = "boardId";

    private readonly ISender _sender;
    private readonly IApplicationDbContext _db;
    private readonly IPresenceService _presence;
    private readonly ILogger<BoardHub> _logger;

    /// <summary>Initializes the hub with required services.</summary>
    public BoardHub(ISender sender, IApplicationDbContext db,
        IPresenceService presence, ILogger<BoardHub> logger)
    {
        _sender = sender;
        _db = db;
        _presence = presence;
        _logger = logger;
    }

    // ── Client → Server methods ───────────────────────────────────────────────

    /// <summary>
    /// Joins the board group, tracks presence, and broadcasts <c>UserJoined</c>
    /// to other members. Returns the current online-user list to the caller.
    /// </summary>
    public async Task<IReadOnlyList<OnlineUserDto>> JoinBoard(Guid boardId)
    {
        var (userId, userName) = GetCaller();

        bool canAccess = await _db.Boards
            .AnyAsync(b => b.Id == boardId
                        && (b.OwnerId == userId
                            || b.Members.Any(m => m.UserId == userId)));

        if (!canAccess)
        {
            _logger.LogWarning("User {UserId} attempted to join board {BoardId} without access",
                userId, boardId);
            return Array.Empty<OnlineUserDto>();
        }

        Context.Items[BoardIdKey] = boardId;
        await Groups.AddToGroupAsync(Context.ConnectionId, GroupName(boardId));

        await _presence.TrackJoinAsync(boardId, userId, userName);
        await Clients.OthersInGroup(GroupName(boardId)).UserJoined(userId, userName, boardId);

        // Return the full presence list so the joining client can populate avatars
        return await _presence.GetOnlineUsersAsync(boardId);
    }

    /// <summary>
    /// Moves a card via <see cref="MoveCardCommand"/> and broadcasts
    /// <c>CardMoved</c> to the entire group (caller included for reconciliation).
    /// </summary>
    public async Task MoveCard(Guid cardId, Guid toColumnId, int newOrder)
    {
        var (userId, _) = GetCaller();

        var fromColumnId = await _db.TaskCards
            .Where(t => t.Id == cardId)
            .Select(t => t.ColumnId)
            .FirstOrDefaultAsync();

        if (fromColumnId == Guid.Empty) return;

        var result = await _sender.Send(new MoveCardCommand(cardId, toColumnId, newOrder, userId));

        if (!result.IsSuccess)
        {
            _logger.LogWarning("MoveCard failed for card {CardId}: {Error}",
                cardId, result.Errors[0]);
            return;
        }

        if (Context.Items[BoardIdKey] is not Guid boardId) return;

        await Clients.Group(GroupName(boardId))
            .CardMoved(cardId, fromColumnId, toColumnId, result.Value!.Order);
    }

    /// <summary>
    /// Removes the connection from the board group and broadcasts <c>UserLeft</c>.
    /// </summary>
    public async Task LeaveBoard(Guid boardId)
    {
        var (userId, _) = GetCaller();
        Context.Items.Remove(BoardIdKey);
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, GroupName(boardId));
        await _presence.TrackLeaveAsync(boardId, userId);
        await Clients.Group(GroupName(boardId)).UserLeft(userId, boardId);
    }

    // ── Lifecycle ─────────────────────────────────────────────────────────────

    /// <inheritdoc />
    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        if (Context.Items.TryGetValue(BoardIdKey, out var raw) && raw is Guid boardId)
        {
            var (userId, _) = GetCaller();
            await _presence.TrackLeaveAsync(boardId, userId);
            await Clients.Group(GroupName(boardId)).UserLeft(userId, boardId);
        }

        await base.OnDisconnectedAsync(exception);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private (Guid userId, string userName) GetCaller()
    {
        var sub = Context.User?.FindFirstValue(ClaimTypes.NameIdentifier)
               ?? Context.User?.FindFirstValue("sub")
               ?? throw new HubException("Unauthenticated connection.");

        var name = Context.User?.FindFirstValue(ClaimTypes.Name)
                ?? Context.User?.FindFirstValue("name")
                ?? "Unknown";

        return (Guid.Parse(sub), name);
    }

    private static string GroupName(Guid boardId) => $"board:{boardId}";
}
