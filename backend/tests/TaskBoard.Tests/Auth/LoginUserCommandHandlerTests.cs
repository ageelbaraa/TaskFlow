using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Moq;
using TaskBoard.Application.Auth.Commands.LoginUser;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Domain.Entities;
using TaskBoard.Infrastructure.Persistence;
using Xunit;

namespace TaskBoard.Tests.Auth;

/// <summary>Unit tests for <see cref="LoginUserCommandHandler"/>.</summary>
public sealed class LoginUserCommandHandlerTests
{
    private static ApplicationDbContext CreateInMemoryContext()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new ApplicationDbContext(options);
    }

    private static User SeedUser(ApplicationDbContext db, string email, string plainPassword)
    {
        var user = new User
        {
            Name = "Test User",
            Email = email.ToLowerInvariant(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(plainPassword),
            Role = Domain.Enums.UserRole.Member
        };
        db.Users.Add(user);
        db.SaveChanges();
        return user;
    }

    [Fact]
    public async Task Handle_CorrectCredentials_ReturnsSuccessWithToken()
    {
        // Arrange
        using var db = CreateInMemoryContext();
        SeedUser(db, "carol@example.com", "Secure123");

        var jwtMock = new Mock<IJwtService>();
        jwtMock.Setup(j => j.GenerateToken(It.IsAny<User>())).Returns("valid-token");

        var handler = new LoginUserCommandHandler(db, jwtMock.Object);

        // Act
        var result = await handler.Handle(
            new LoginUserCommand("carol@example.com", "Secure123"),
            CancellationToken.None);

        // Assert
        result.IsSuccess.Should().BeTrue();
        result.Value!.AccessToken.Should().Be("valid-token");
    }

    [Fact]
    public async Task Handle_WrongPassword_ReturnsFailure()
    {
        // Arrange
        using var db = CreateInMemoryContext();
        SeedUser(db, "dave@example.com", "Correct1");

        var jwtMock = new Mock<IJwtService>();
        var handler = new LoginUserCommandHandler(db, jwtMock.Object);

        // Act
        var result = await handler.Handle(
            new LoginUserCommand("dave@example.com", "WrongPass"),
            CancellationToken.None);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Errors.Should().ContainSingle(e => e.Contains("Invalid email or password"));
    }

    [Fact]
    public async Task Handle_UnknownEmail_ReturnsFailure()
    {
        // Arrange
        using var db = CreateInMemoryContext();
        var jwtMock = new Mock<IJwtService>();
        var handler = new LoginUserCommandHandler(db, jwtMock.Object);

        // Act
        var result = await handler.Handle(
            new LoginUserCommand("nobody@example.com", "Password1"),
            CancellationToken.None);

        // Assert
        result.IsFailure.Should().BeTrue();
    }
}
