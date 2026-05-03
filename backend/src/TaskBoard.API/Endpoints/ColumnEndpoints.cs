using System.Security.Claims;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using TaskBoard.Application.Columns.Commands.CreateColumn;
using TaskBoard.Application.Columns.Commands.DeleteColumn;
using TaskBoard.Application.Columns.Commands.UpdateColumn;

namespace TaskBoard.API.Endpoints;

/// <summary>Maps column CRUD endpoints under <c>/boards/{boardId}/columns</c>.</summary>
public static class ColumnEndpoints
{
    /// <summary>Registers column routes. All require authentication.</summary>
    public static IEndpointRouteBuilder MapColumnEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/boards/{boardId:guid}/columns")
            .WithTags("Columns")
            .WithOpenApi()
            .RequireAuthorization();

        group.MapPost("/", CreateColumnAsync).WithName("CreateColumn").WithSummary("Add a column to a board.");
        group.MapPut("/{columnId:guid}", UpdateColumnAsync).WithName("UpdateColumn").WithSummary("Rename a column.");
        group.MapDelete("/{columnId:guid}", DeleteColumnAsync).WithName("DeleteColumn").WithSummary("Delete a column.");

        return app;
    }

    private static async Task<IResult> CreateColumnAsync(
        Guid boardId,
        [FromBody] CreateColumnRequest req,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken ct)
    {
        var result = await sender.Send(new CreateColumnCommand(boardId, req.Title, GetUserId(user)), ct);
        return result.IsSuccess
            ? Results.Created($"/boards/{boardId}/columns/{result.Value!.Id}", result.Value)
            : Results.Problem(result.Errors[0]);
    }

    private static async Task<IResult> UpdateColumnAsync(
        Guid boardId,
        Guid columnId,
        [FromBody] UpdateColumnRequest req,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken ct)
    {
        var result = await sender.Send(new UpdateColumnCommand(columnId, req.Title, GetUserId(user)), ct);
        return result.IsSuccess ? Results.Ok(result.Value) : Results.Problem(result.Errors[0]);
    }

    private static async Task<IResult> DeleteColumnAsync(
        Guid boardId,
        Guid columnId,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken ct)
    {
        var result = await sender.Send(new DeleteColumnCommand(columnId, GetUserId(user)), ct);
        return result.IsSuccess ? Results.NoContent() : Results.Problem(result.Errors[0]);
    }

    private static Guid GetUserId(ClaimsPrincipal user)
    {
        var sub = user.FindFirstValue(ClaimTypes.NameIdentifier)
               ?? user.FindFirstValue("sub")
               ?? throw new UnauthorizedAccessException("User identity not found.");
        return Guid.Parse(sub);
    }

    private sealed record CreateColumnRequest(string Title);
    private sealed record UpdateColumnRequest(string Title);
}
