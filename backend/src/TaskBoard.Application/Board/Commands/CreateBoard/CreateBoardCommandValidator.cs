using FluentValidation;

namespace TaskBoard.Application.Board.Commands.CreateBoard;

/// <summary>Validates <see cref="CreateBoardCommand"/>.</summary>
public sealed class CreateBoardCommandValidator : AbstractValidator<CreateBoardCommand>
{
    /// <summary>Initializes validation rules.</summary>
    public CreateBoardCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Board name is required.")
            .MaximumLength(200).WithMessage("Board name must not exceed 200 characters.");

        RuleFor(x => x.UserId)
            .NotEmpty().WithMessage("UserId is required.");
    }
}
