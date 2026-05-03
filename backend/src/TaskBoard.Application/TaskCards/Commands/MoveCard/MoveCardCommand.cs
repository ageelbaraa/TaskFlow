using MediatR;
using TaskBoard.Application.Common.Models;
using TaskBoard.Application.TaskCards.DTOs;

namespace TaskBoard.Application.TaskCards.Commands.MoveCard;

/// <summary>
/// Moves a card to a (possibly different) column and inserts it at the specified order index.
/// All sibling cards in the destination column are re-indexed to maintain contiguous ordering.
/// This command is also invoked by the SignalR hub in Phase 3.
/// </summary>
/// <param name="CardId">Card to move.</param>
/// <param name="ToColumnId">Destination column (may equal the source column for reordering).</param>
/// <param name="NewOrder">Zero-based target index within the destination column.</param>
/// <param name="UserId">Requesting user identifier.</param>
public sealed record MoveCardCommand(Guid CardId, Guid ToColumnId, int NewOrder, Guid UserId)
    : IRequest<Result<TaskCardDto>>;
