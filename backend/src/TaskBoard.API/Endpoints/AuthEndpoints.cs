using MediatR;
using Microsoft.AspNetCore.Mvc;
using TaskBoard.Application.Auth.Commands.LoginUser;
using TaskBoard.Application.Auth.Commands.RegisterUser;

namespace TaskBoard.API.Endpoints;

/// <summary>Maps authentication-related HTTP endpoints onto the Minimal API pipeline.</summary>
public static class AuthEndpoints
{
    /// <summary>Registers POST /auth/register and POST /auth/login routes.</summary>
    public static IEndpointRouteBuilder MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/auth")
            .WithTags("Authentication")
            .WithOpenApi();

        group.MapPost("/register", RegisterAsync)
            .WithName("Register")
            .WithSummary("Create a new user account and receive a JWT.")
            .Produces(StatusCodes.Status200OK)
            .Produces<ProblemDetails>(StatusCodes.Status400BadRequest)
            .Produces<ProblemDetails>(StatusCodes.Status409Conflict);

        group.MapPost("/login", LoginAsync)
            .WithName("Login")
            .WithSummary("Authenticate with email and password, receive a JWT.")
            .Produces(StatusCodes.Status200OK)
            .Produces<ProblemDetails>(StatusCodes.Status400BadRequest)
            .Produces<ProblemDetails>(StatusCodes.Status401Unauthorized);

        return app;
    }

    private static async Task<IResult> RegisterAsync(
        [FromBody] RegisterUserCommand command,
        ISender sender,
        CancellationToken ct)
    {
        var result = await sender.Send(command, ct);

        return result.IsSuccess
            ? Results.Ok(result.Value)
            : Results.Conflict(new ProblemDetails
            {
                Status = StatusCodes.Status409Conflict,
                Title = "Registration Failed",
                Detail = result.Errors.FirstOrDefault()
            });
    }

    private static async Task<IResult> LoginAsync(
        [FromBody] LoginUserCommand command,
        ISender sender,
        CancellationToken ct)
    {
        var result = await sender.Send(command, ct);

        return result.IsSuccess
            ? Results.Ok(result.Value)
            : Results.Unauthorized();
    }
}
