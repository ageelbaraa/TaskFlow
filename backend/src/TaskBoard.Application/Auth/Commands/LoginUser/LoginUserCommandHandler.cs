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

    /// <summary>Initializes the handler with required services.</summary>
    public LoginUserCommandHandler(IApplicationDbContext db, IJwtService jwt)
    {
        _db = db;
        _jwt = jwt;
    }

    /// <inheritdoc />
    public async Task<Result<AuthResponseDto>> Handle(
        LoginUserCommand request,
        CancellationToken cancellationToken)
    {
        var user = await _db.Users
            .FirstOrDefaultAsync(u => u.Email == request.Email.ToLowerInvariant(), cancellationToken);

        if (user is null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            return Result<AuthResponseDto>.Failure("Invalid email or password.");

        string token = _jwt.GenerateToken(user);
        var expiry = DateTime.UtcNow.AddHours(24);

        return Result<AuthResponseDto>.Success(
            new AuthResponseDto(token, expiry, user.Id, user.Name, user.Email, user.Role.ToString()));
    }
}
