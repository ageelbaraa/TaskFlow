using MediatR;
using TaskBoard.Application.Auth.DTOs;
using TaskBoard.Application.Common.Models;

namespace TaskBoard.Application.Auth.Commands.LoginUser;

/// <summary>Authenticates a user with email and password, returning a JWT on success.</summary>
/// <param name="Email">The registered email address.</param>
/// <param name="Password">The plain-text password to verify.</param>
public sealed record LoginUserCommand(string Email, string Password)
    : IRequest<Result<AuthResponseDto>>;
