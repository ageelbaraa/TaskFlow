using System.Security.Claims;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using TaskBoard.Application.Board.Commands.CreateBoard;
using TaskBoard.Application.Board.Commands.DeleteBoard;
using TaskBoard.Application.Board.Commands.UpdateBoard;
using TaskBoard.Application.Board.Queries.GetBoardById;
using TaskBoard.Application.Board.Queries.GetBoards;

namespace TaskBoard.API.Endpoints;

/// <summary>Maps board CRUD endpoints under <c>/boards</c>.</summary>
public static class BoardEndpoints
{
    /// <summary>Registers all board routes. All routes require authentication.</summary>
    public static IEndpointRouteBuilder MapBoardEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/boards")
            .WithTags("Boards")
            .WithOpenApi()
            .RequireAuthorization();

        group.MapGet("/", GetBoardsAsync).WithName("GetBoards").WithSummary("List boards for the current user.");
        group.MapGet("/{id:guid}", GetBoardByIdAsync).WithName("GetBoardById").WithSummary("Get full board detail.");
        group.MapPost("/", CreateBoardAsync).WithName("CreateBoard").WithSummary("Create a new board.");
        group.MapPut("/{id:guid}", UpdateBoardAsync).WithName("UpdateBoard").WithSummary("Rename a board.");
        group.MapDelete("/{id:guid}", DeleteBoardAsync).WithName("DeleteBoard").WithSummary("Delete a board.");

        return app;
    }

    private static async Task<IResult> GetBoardsAsync(ClaimsPrincipal user, ISender sender, CancellationToken ct)
    {
        var userId = GetUserId(user);
        var boards = await sender.Send(new GetBoardsQuery(userId), ct);
        return Results.Ok(boards);
    }

    private static async Task<IResult> GetBoardByIdAsync(
        Guid id, ClaimsPrincipal user, ISender sender, CancellationToken ct)
    {
        var board = await sender.Send(new GetBoardByIdQuery(id, GetUserId(user)), ct);
        return board is null ? Results.NotFound() : Results.Ok(board);
    }

    private static async Task<IResult> CreateBoardAsync(
        [FromBody] CreateBoardRequest req, ClaimsPrincipal user, ISender sender, CancellationToken ct)
    {
        var result = await sender.Send(new CreateBoardCommand(req.Name, GetUserId(user)), ct);
        return result.IsSuccess
            ? Results.Created($"/boards/{result.Value!.Id}", result.Value)
            : Results.BadRequest(result.Errors);
    }

    private static async Task<IResult> UpdateBoardAsync(
        Guid id, [FromBody] UpdateBoardRequest req, ClaimsPrincipal user, ISender sender, CancellationToken ct)
    {
        var result = await sender.Send(new UpdateBoardCommand(id, req.Name, GetUserId(user)), ct);
        return result.IsSuccess ? Results.Ok(result.Value) : Results.Problem(result.Errors[0]);
    }

    private static async Task<IResult> DeleteBoardAsync(
        Guid id, ClaimsPrincipal user, ISender sender, CancellationToken ct)
    {
        var result = await sender.Send(new DeleteBoardCommand(id, GetUserId(user)), ct);
        return result.IsSuccess ? Results.NoContent() : Results.Problem(result.Errors[0]);
    }

    private static Guid GetUserId(ClaimsPrincipal user)
    {
        var sub = user.FindFirstValue(ClaimTypes.NameIdentifier)
               ?? user.FindFirstValue("sub")
               ?? throw new UnauthorizedAccessException("User identity not found.");
        return Guid.Parse(sub);
    }

    private sealed record CreateBoardRequest(string Name);
    private sealed record UpdateBoardRequest(string Name);
}
