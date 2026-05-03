using FluentValidation;

namespace TaskBoard.Application.TaskCards.Commands.CreateTaskCard;

/// <summary>Validates <see cref="CreateTaskCardCommand"/>.</summary>
public sealed class CreateTaskCardCommandValidator : AbstractValidator<CreateTaskCardCommand>
{
    /// <summary>Initializes validation rules.</summary>
    public CreateTaskCardCommandValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Card title is required.")
            .MaximumLength(300).WithMessage("Card title must not exceed 300 characters.");

        RuleFor(x => x.Description)
            .MaximumLength(4000).WithMessage("Description must not exceed 4000 characters.")
            .When(x => x.Description is not null);

        RuleFor(x => x.ColumnId).NotEmpty();
        RuleFor(x => x.UserId).NotEmpty();
    }
}
