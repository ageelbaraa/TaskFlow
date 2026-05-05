using MediatR;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Auth.DTOs;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Application.Common.Models;

namespace TaskBoard.Application.Auth.Commands.LoginUser;

/// <summary>Handles <see cref="LoginUserCommand"/>: verifies credentials and issues a JWT.</summary>
public sealed class LoginUserCommandHandler
    : IRequestHandler<LoginUserCommand, Result<AuthResponseDto>>
{
    private readonly IApplicationDbContext _db;
    private readonly IJwtService _jwt;
    private readonly IPasswordHasher _hasher;

    /// <summary>Initializes the handler with required services.</summary>
    public LoginUserCommandHandler(
        IApplicationDbContext db,
        IJwtService jwt,
        IPasswordHasher hasher)
    {
        _db = db;
        _jwt = jwt;
        _hasher = hasher;
    }

    /// <inheritdoc />
    public async Task<Result<AuthResponseDto>> Handle(
        LoginUserCommand request,
        CancellationToken cancellationToken)
    {
        var user = await _db.Users
            .FirstOrDefaultAsync(u => u.Email == request.Email.ToLowerInvariant(), cancellationToken);

        // Separate null-check from hash-verify so the compiler knows 'user'
        // is non-null at the GenerateToken call site (fixes CS8604).
        if (user is null || !_hasher.Verify(request.Password, user.PasswordHash))
            return Result<AuthResponseDto>.Failure("Invalid email or password.");

        string token = _jwt.GenerateToken(user);
        var expiry = DateTime.UtcNow.AddHours(24);

        return Result<AuthResponseDto>.Success(
            new AuthResponseDto(token, expiry, user.Id, user.Name, user.Email, user.Role.ToString()));
    }
}
