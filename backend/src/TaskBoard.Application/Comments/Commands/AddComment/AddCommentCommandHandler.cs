using MediatR;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Comments.DTOs;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Application.Common.Models;
using TaskBoard.Domain.Entities;

namespace TaskBoard.Application.Comments.Commands.AddComment;

/// <summary>Handles <see cref="AddCommentCommand"/>: validates access, persists the comment, returns DTO.</summary>
public sealed class AddCommentCommandHandler : IRequestHandler<AddCommentCommand, Result<CommentDto>>
{
    private readonly IApplicationDbContext _db;

    /// <summary>Initializes the handler.</summary>
    public AddCommentCommandHandler(IApplicationDbContext db) => _db = db;

    /// <inheritdoc />
    public async Task<Result<CommentDto>> Handle(
        AddCommentCommand request,
        CancellationToken cancellationToken)
    {
        var card = await _db.TaskCards
            .Include(t => t.Column).ThenInclude(c => c.Board).ThenInclude(b => b.Members)
            .FirstOrDefaultAsync(t => t.Id == request.TaskCardId, cancellationToken);

        if (card is null) return Result<CommentDto>.Failure("Card not found.");

        bool canAccess = card.Column.Board.OwnerId == request.AuthorId
            || card.Column.Board.Members.Any(m => m.UserId == request.AuthorId);

        if (!canAccess) return Result<CommentDto>.Failure("Access denied.");

        var author = await _db.Users
            .FirstOrDefaultAsync(u => u.Id == request.AuthorId, cancellationToken);

        if (author is null) return Result<CommentDto>.Failure("Author not found.");

        var comment = new Comment
        {
            TaskCardId = request.TaskCardId,
            AuthorId = request.AuthorId,
            Body = request.Body.Trim()
        };

        _db.Comments.Add(comment);
        await _db.SaveChangesAsync(cancellationToken);

        return Result<CommentDto>.Success(new CommentDto(
            comment.Id,
            comment.TaskCardId,
            card.Column.BoardId,
            comment.AuthorId,
            author.Name,
            comment.Body,
            comment.CreatedAt));
    }
}
