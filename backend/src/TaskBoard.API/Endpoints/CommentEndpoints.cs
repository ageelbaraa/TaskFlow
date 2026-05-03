using System.Security.Claims;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using TaskBoard.API.Hubs;
using TaskBoard.Application.Comments.Commands.AddComment;
using TaskBoard.Application.Comments.Queries.GetComments;

namespace TaskBoard.API.Endpoints;

/// <summary>Maps comment endpoints under <c>/tasks/{taskId}/comments</c>.</summary>
public static class CommentEndpoints
{
    /// <summary>Registers comment routes. All require authentication.</summary>
    public static IEndpointRouteBuilder MapCommentEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/tasks/{taskId:guid}/comments")
            .WithTags("Comments")
            .WithOpenApi()
            .RequireAuthorization();

        group.MapGet("/", GetCommentsAsync)
            .WithName("GetComments")
            .WithSummary("List all comments on a task card.");

        group.MapPost("/", AddCommentAsync)
            .WithName("AddComment")
            .WithSummary("Post a comment and broadcast it via SignalR.");

        return app;
    }

    private static async Task<IResult> GetCommentsAsync(
        Guid taskId,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken ct)
    {
        var comments = await sender.Send(new GetCommentsQuery(taskId, GetUserId(user)), ct);
        return Results.Ok(comments);
    }

    private static async Task<IResult> AddCommentAsync(
        Guid taskId,
        [FromBody] AddCommentRequest req,
        ClaimsPrincipal user,
        ISender sender,
        IHubContext<BoardHub, IBoardHubClient> hubContext,
        CancellationToken ct)
    {
        var result = await sender.Send(new AddCommentCommand(taskId, req.Body, GetUserId(user)), ct);

        if (!result.IsSuccess)
            return Results.Problem(result.Errors[0]);

        var dto = result.Value!;

        // Broadcast to all connected clients on this board so their comment
        // feeds update in real time without polling.
        await hubContext.Clients
            .Group($"board:{dto.BoardId}")
            .CommentAdded(dto.TaskCardId, dto);

        return Results.Created($"/tasks/{taskId}/comments/{dto.Id}", dto);
    }

    private static Guid GetUserId(ClaimsPrincipal user)
    {
        var sub = user.FindFirstValue(ClaimTypes.NameIdentifier)
               ?? user.FindFirstValue("sub")
               ?? throw new UnauthorizedAccessException("User identity not found.");
        return Guid.Parse(sub);
    }

    private sealed record AddCommentRequest(string Body);
}
