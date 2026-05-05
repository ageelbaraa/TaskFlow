namespace TaskBoard.Application.Common.Interfaces;

/// <summary>Abstracts password hashing so the Application layer has no direct
/// dependency on a concrete hashing library (e.g. BCrypt.Net).</summary>
public interface IPasswordHasher
{
    /// <summary>Produces a salted hash of <paramref name="password"/>.</summary>
    string Hash(string password);

    /// <summary>Returns <c>true</c> when <paramref name="password"/> matches
    /// the previously hashed value <paramref name="hash"/>.</summary>
    bool Verify(string password, string hash);
}
