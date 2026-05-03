namespace TaskBoard.Application.Common.DTOs;

/// <summary>Represents a user who is currently online on a board.</summary>
/// <param name="UserId">The user's identifier.</param>
/// <param name="UserName">The user's display name.</param>
public sealed record OnlineUserDto(Guid UserId, string UserName);
