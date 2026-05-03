using FluentValidation;

namespace TaskBoard.Application.Columns.Commands.CreateColumn;

/// <summary>Validates <see cref="CreateColumnCommand"/>.</summary>
public sealed class CreateColumnCommandValidator : AbstractValidator<CreateColumnCommand>
{
    /// <summary>Initializes validation rules.</summary>
    public CreateColumnCommandValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Column title is required.")
            .MaximumLength(100).WithMessage("Column title must not exceed 100 characters.");

        RuleFor(x => x.BoardId).NotEmpty();
        RuleFor(x => x.UserId).NotEmpty();
    }
}
