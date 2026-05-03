using System.Security.Claims;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using TaskBoard.Application.TaskCards.Commands.CreateTaskCard;
using TaskBoard.Application.TaskCards.Commands.DeleteTaskCard;
using TaskBoard.Application.TaskCards.Commands.MoveCard;
using TaskBoard.Application.TaskCards.Commands.UpdateTaskCard;
using TaskBoard.Domain.Enums;

namespace TaskBoard.API.Endpoints;

/// <summary>Maps task card CRUD and move endpoints under <c>/cards</c>.</summary>
public static class TaskCardEndpoints
{
    /// <summary>Registers card routes. All require authentication.</summary>
    public static IEndpointRouteBuilder MapTaskCardEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/cards")
            .WithTags("TaskCards")
            .WithOpenApi()
            .RequireAuthorization();

        group.MapPost("/", CreateCardAsync).WithName("CreateCard").WithSummary("Create a task card.");
        group.MapPut("/{id:guid}", UpdateCardAsync).WithName("UpdateCard").WithSummary("Update a task card.");
        group.MapDelete("/{id:guid}", DeleteCardAsync).WithName("DeleteCard").WithSummary("Delete a task card.");
        group.MapPatch("/{id:guid}/move", MoveCardAsync).WithName("MoveCard").WithSummary("Move card to column at order.");

        return app;
    }

    private static async Task<IResult> CreateCardAsync(
        [FromBody] CreateCardRequest req, ClaimsPrincipal user, ISender sender, CancellationToken ct)
    {
        var result = await sender.Send(new CreateTaskCardCommand(
            req.ColumnId, req.Title, req.Description,
            req.AssigneeId, req.Priority, req.DueDate, GetUserId(user)), ct);

        return result.IsSuccess
            ? Results.Created($"/cards/{result.Value!.Id}", result.Value)
            : Results.Problem(result.Errors[0]);
    }

    private static async Task<IResult> UpdateCardAsync(
        Guid id, [FromBody] UpdateCardRequest req, ClaimsPrincipal user, ISender sender, CancellationToken ct)
    {
        var result = await sender.Send(new UpdateTaskCardCommand(
            id, req.Title, req.Description,
            req.AssigneeId, req.Priority, req.DueDate, GetUserId(user)), ct);

        return result.IsSuccess ? Results.Ok(result.Value) : Results.Problem(result.Errors[0]);
    }

    private static async Task<IResult> DeleteCardAsync(
        Guid id, ClaimsPrincipal user, ISender sender, CancellationToken ct)
    {
        var result = await sender.Send(new DeleteTaskCardCommand(id, GetUserId(user)), ct);
        return result.IsSuccess ? Results.NoContent() : Results.Problem(result.Errors[0]);
    }

    private static async Task<IResult> MoveCardAsync(
        Guid id, [FromBody] MoveCardRequest req, ClaimsPrincipal user, ISender sender, CancellationToken ct)
    {
        var result = await sender.Send(new MoveCardCommand(id, req.ToColumnId, req.NewOrder, GetUserId(user)), ct);
        return result.IsSuccess ? Results.Ok(result.Value) : Results.Problem(result.Errors[0]);
    }

    private static Guid GetUserId(ClaimsPrincipal user)
    {
        var sub = user.FindFirstValue(ClaimTypes.NameIdentifier)
               ?? user.FindFirstValue("sub")
               ?? throw new UnauthorizedAccessException("User identity not found.");
        return Guid.Parse(sub);
    }

    private sealed record CreateCardRequest(
        Guid ColumnId, string Title, string? Description,
        Guid? AssigneeId, Priority Priority, DateTime? DueDate);

    private sealed record UpdateCardRequest(
        string Title, string? Description,
        Guid? AssigneeId, Priority Priority, DateTime? DueDate);

    private sealed record MoveCardRequest(Guid ToColumnId, int NewOrder);
}
