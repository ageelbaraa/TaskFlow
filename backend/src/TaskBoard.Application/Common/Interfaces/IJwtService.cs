using TaskBoard.Domain.Entities;

namespace TaskBoard.Application.Common.Interfaces;

/// <summary>Generates and validates JSON Web Tokens for authenticated users.</summary>
public interface IJwtService
{
    /// <summary>
    /// Creates a signed JWT access token embedding the user's identity claims.
    /// </summary>
    /// <param name="user">The authenticated user for whom the token is issued.</param>
    /// <returns>A compact-serialized JWT string.</returns>
    string GenerateToken(User user);
}
