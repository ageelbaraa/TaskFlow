using MediatR;
using TaskBoard.Application.Auth.DTOs;
using TaskBoard.Application.Common.Models;

namespace TaskBoard.Application.Auth.Commands.RegisterUser;

/// <summary>Creates a new user account and returns a JWT on success.</summary>
/// <param name="Name">The display name for the new user.</param>
/// <param name="Email">The unique email address (used as login credential).</param>
/// <param name="Password">The plain-text password — will be hashed before storage.</param>
public sealed record RegisterUserCommand(string Name, string Email, string Password)
    : IRequest<Result<AuthResponseDto>>;
