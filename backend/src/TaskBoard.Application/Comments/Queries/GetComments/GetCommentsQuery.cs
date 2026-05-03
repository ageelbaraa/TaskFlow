using MediatR;
using TaskBoard.Application.Comments.DTOs;

namespace TaskBoard.Application.Comments.Queries.GetComments;

/// <summary>Returns all comments on a task card, ordered chronologically.</summary>
/// <param name="TaskCardId">The card whose comments to retrieve.</param>
/// <param name="UserId">Requesting user (access check).</param>
public sealed record GetCommentsQuery(Guid TaskCardId, Guid UserId)
    : IRequest<IReadOnlyList<CommentDto>>;
