using MediatR;
using TaskBoard.Application.Comments.DTOs;
using TaskBoard.Application.Common.Models;

namespace TaskBoard.Application.Comments.Commands.AddComment;

/// <summary>Posts a new comment on a task card.</summary>
/// <param name="TaskCardId">The card to comment on.</param>
/// <param name="Body">Markdown comment body.</param>
/// <param name="AuthorId">The authenticated user posting the comment.</param>
public sealed record AddCommentCommand(Guid TaskCardId, string Body, Guid AuthorId)
    : IRequest<Result<CommentDto>>;
