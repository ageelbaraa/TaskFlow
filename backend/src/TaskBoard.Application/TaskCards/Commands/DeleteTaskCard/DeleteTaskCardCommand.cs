using MediatR;
using TaskBoard.Application.Common.Models;

namespace TaskBoard.Application.TaskCards.Commands.DeleteTaskCard;

/// <summary>Deletes a task card and all its comments.</summary>
/// <param name="CardId">Card to delete.</param>
/// <param name="UserId">Requesting user.</param>
public sealed record DeleteTaskCardCommand(Guid CardId, Guid UserId)
    : IRequest<Result<bool>>;
