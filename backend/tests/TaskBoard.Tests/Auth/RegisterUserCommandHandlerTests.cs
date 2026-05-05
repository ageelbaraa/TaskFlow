using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Moq;
using TaskBoard.Application.Auth.Commands.RegisterUser;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Infrastructure.Persistence;
using TaskBoard.Infrastructure.Services;
using Xunit;

namespace TaskBoard.Tests.Auth;

/// <summary>Unit tests for <see cref="RegisterUserCommandHandler"/>.</summary>
public sealed class RegisterUserCommandHandlerTests
{
    private static readonly IPasswordHasher Hasher = new PasswordHasher();

    private static ApplicationDbContext CreateInMemoryContext()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new ApplicationDbContext(options);
    }

    [Fact]
    public async Task Handle_ValidCommand_ReturnsSuccessWithToken()
    {
        using var db = CreateInMemoryContext();
        var jwtMock = new Mock<IJwtService>();
        jwtMock.Setup(j => j.GenerateToken(It.IsAny<Domain.Entities.User>()))
               .Returns("mock-jwt-token");

        var handler = new RegisterUserCommandHandler(db, jwtMock.Object, Hasher);
        var command = new RegisterUserCommand("Alice", "alice@example.com", "Password1");

        var result = await handler.Handle(command, CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Value!.AccessToken.Should().Be("mock-jwt-token");
        result.Value.Email.Should().Be("alice@example.com");
        result.Value.Name.Should().Be("Alice");
    }

    [Fact]
    public async Task Handle_DuplicateEmail_ReturnsFailure()
    {
        using var db = CreateInMemoryContext();
        var jwtMock = new Mock<IJwtService>();
        jwtMock.Setup(j => j.GenerateToken(It.IsAny<Domain.Entities.User>()))
               .Returns("token");

        var handler = new RegisterUserCommandHandler(db, jwtMock.Object, Hasher);
        var command = new RegisterUserCommand("Alice", "alice@example.com", "Password1");

        await handler.Handle(command, CancellationToken.None);

        // Register same email again
        var result = await handler.Handle(command, CancellationToken.None);

        result.IsFailure.Should().BeTrue();
        result.Errors.Should().ContainSingle(e => e.Contains("already exists"));
    }

    [Fact]
    public async Task Handle_EmailNormalisedToLowercase()
    {
        using var db = CreateInMemoryContext();
        var jwtMock = new Mock<IJwtService>();
        jwtMock.Setup(j => j.GenerateToken(It.IsAny<Domain.Entities.User>())).Returns("token");

        var handler = new RegisterUserCommandHandler(db, jwtMock.Object, Hasher);
        var command = new RegisterUserCommand("Bob", "BOB@EXAMPLE.COM", "Password1");

        var result = await handler.Handle(command, CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Value!.Email.Should().Be("bob@example.com");
    }
}
