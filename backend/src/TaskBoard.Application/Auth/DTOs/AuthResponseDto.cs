namespace TaskBoard.Application.Auth.DTOs;

/// <summary>Returned to the client after successful authentication.</summary>
/// <param name="AccessToken">The JWT bearer token to attach to subsequent requests.</param>
/// <param name="ExpiresAt">UTC timestamp when the token expires.</param>
/// <param name="UserId">The authenticated user's identifier.</param>
/// <param name="Name">The authenticated user's display name.</param>
/// <param name="Email">The authenticated user's email address.</param>
/// <param name="Role">The authenticated user's role string.</param>
public sealed record AuthResponseDto(
    string AccessToken,
    DateTime ExpiresAt,
    Guid UserId,
    string Name,
    string Email,
    string Role);
