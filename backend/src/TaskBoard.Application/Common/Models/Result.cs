namespace TaskBoard.Application.Common.Models;

/// <summary>
/// Discriminated union representing either a successful value or a list of error messages.
/// Use this as the return type of all command/query handlers instead of throwing exceptions
/// for domain-level failures.
/// </summary>
/// <typeparam name="T">The type of the success value.</typeparam>
public sealed class Result<T>
{
    private Result(T value)
    {
        Value = value;
        IsSuccess = true;
        Errors = Array.Empty<string>();
    }

    private Result(IEnumerable<string> errors)
    {
        Value = default;
        IsSuccess = false;
        Errors = errors.ToArray();
    }

    /// <summary>Gets whether the operation succeeded.</summary>
    public bool IsSuccess { get; }

    /// <summary>Gets whether the operation failed.</summary>
    public bool IsFailure => !IsSuccess;

    /// <summary>Gets the success value. Only valid when <see cref="IsSuccess"/> is true.</summary>
    public T? Value { get; }

    /// <summary>Gets the list of error messages. Non-empty only when <see cref="IsFailure"/> is true.</summary>
    public string[] Errors { get; }

    /// <summary>Creates a successful result wrapping the given value.</summary>
    public static Result<T> Success(T value) => new(value);

    /// <summary>Creates a failed result with a single error message.</summary>
    public static Result<T> Failure(string error) => new(new[] { error });

    /// <summary>Creates a failed result with multiple error messages.</summary>
    public static Result<T> Failure(IEnumerable<string> errors) => new(errors);
}
