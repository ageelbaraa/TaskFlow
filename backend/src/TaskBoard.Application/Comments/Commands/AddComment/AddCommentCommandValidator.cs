using FluentValidation;

namespace TaskBoard.Application.Comments.Commands.AddComment;

/// <summary>Validates <see cref="AddCommentCommand"/>.</summary>
public sealed class AddCommentCommandValidator : AbstractValidator<AddCommentCommand>
{
    /// <summary>Initializes validation rules.</summary>
    public AddCommentCommandValidator()
    {
        RuleFor(x => x.Body)
            .NotEmpty().WithMessage("Comment body is required.")
            .MaximumLength(4000).WithMessage("Comment must not exceed 4000 characters.");

        RuleFor(x => x.TaskCardId).NotEmpty();
        RuleFor(x => x.AuthorId).NotEmpty();
    }
}
