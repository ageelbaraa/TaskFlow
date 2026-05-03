using MediatR;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Auth.DTOs;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Application.Common.Models;
using TaskBoard.Domain.Entities;
using TaskBoard.Domain.Enums;

namespace TaskBoard.Application.Auth.Commands.RegisterUser;

/// <summary>Handles <see cref="RegisterUserCommand"/>: validates uniqueness, hashes password, persists user, returns JWT.</summary>
public sealed class RegisterUserCommandHandler
    : IRequestHandler<RegisterUserCommand, Result<AuthResponseDto>>
{
    private readonly IApplicationDbContext _db;
    private readonly IJwtService _jwt;

    /// <summary>Initializes the handler with required services.</summary>
    public RegisterUserCommandHandler(IApplicationDbContext db, IJwtService jwt)
    {
        _db = db;
        _jwt = jwt;
    }

    /// <inheritdoc />
    public async Task<Result<AuthResponseDto>> Handle(
        RegisterUserCommand request,
        CancellationToken cancellationToken)
    {
        bool emailTaken = await _db.Users
            .AnyAsync(u => u.Email == request.Email.ToLowerInvariant(), cancellationToken);

        if (emailTaken)
            return Result<AuthResponseDto>.Failure("An account with this email already exists.");

        var user = new User
        {
            Name = request.Name.Trim(),
            Email = request.Email.ToLowerInvariant(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            Role = UserRole.Member
        };

        _db.Users.Add(user);
        await _db.SaveChangesAsync(cancellationToken);

        string token = _jwt.GenerateToken(user);
        var expiry = DateTime.UtcNow.AddHours(24);

        return Result<AuthResponseDto>.Success(
            new AuthResponseDto(token, expiry, user.Id, user.Name, user.Email, user.Role.ToString()));
    }
}
