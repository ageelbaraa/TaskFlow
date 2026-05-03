using FluentValidation;

namespace TaskBoard.Application.Auth.Commands.LoginUser;

/// <summary>Validates input for <see cref="LoginUserCommand"/>.</summary>
public sealed class LoginUserCommandValidator : AbstractValidator<LoginUserCommand>
{
    /// <summary>Initializes validation rules.</summary>
    public LoginUserCommandValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email is required.")
            .EmailAddress().WithMessage("Email must be a valid email address.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required.");
    }
}
