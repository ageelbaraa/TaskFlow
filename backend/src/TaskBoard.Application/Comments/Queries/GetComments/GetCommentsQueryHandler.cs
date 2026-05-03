using MediatR;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Comments.DTOs;
using TaskBoard.Application.Common.Interfaces;

namespace TaskBoard.Application.Comments.Queries.GetComments;

/// <summary>Handles <see cref="GetCommentsQuery"/>.</summary>
public sealed class GetCommentsQueryHandler
    : IRequestHandler<GetCommentsQuery, IReadOnlyList<CommentDto>>
{
    private readonly IApplicationDbContext _db;

    /// <summary>Initializes the handler.</summary>
    public GetCommentsQueryHandler(IApplicationDbContext db) => _db = db;

    /// <inheritdoc />
    public async Task<IReadOnlyList<CommentDto>> Handle(
        GetCommentsQuery request,
        CancellationToken cancellationToken)
    {
        // Verify the user has access to the board this card belongs to
        bool hasAccess = await _db.TaskCards
            .AnyAsync(t => t.Id == request.TaskCardId
                        && (t.Column.Board.OwnerId == request.UserId
                            || t.Column.Board.Members.Any(m => m.UserId == request.UserId)),
                      cancellationToken);

        if (!hasAccess) return Array.Empty<CommentDto>();

        return await _db.Comments
            .Where(c => c.TaskCardId == request.TaskCardId)
            .OrderBy(c => c.CreatedAt)
            .Select(c => new CommentDto(
                c.Id,
                c.TaskCardId,
                c.TaskCard.Column.BoardId,
                c.AuthorId,
                c.Author.Name,
                c.Body,
                c.CreatedAt))
            .ToListAsync(cancellationToken);
    }
}
