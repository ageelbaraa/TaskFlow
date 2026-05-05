using TaskBoard.Application.Common.Interfaces;

namespace TaskBoard.Infrastructure.Services;

/// <summary>BCrypt-backed implementation of <see cref="IPasswordHasher"/>.</summary>
public sealed class PasswordHasher : IPasswordHasher
{
    public string Hash(string password) =>
        BCrypt.Net.BCrypt.HashPassword(password);

    public bool Verify(string password, string hash) =>
        BCrypt.Net.BCrypt.Verify(password, hash);
}
