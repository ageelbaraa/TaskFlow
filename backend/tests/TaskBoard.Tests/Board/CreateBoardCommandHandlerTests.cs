using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Board.Commands.CreateBoard;
using TaskBoard.Domain.Entities;
using TaskBoard.Infrastructure.Persistence;
using Xunit;

namespace TaskBoard.Tests.Board;

/// <summary>Unit tests for <see cref="CreateBoardCommandHandler"/>.</summary>
public sealed class CreateBoardCommandHandlerTests
{
    private static ApplicationDbContext CreateDb()
    {
        var opts = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString()).Options;
        return new ApplicationDbContext(opts);
    }

    private static User SeedUser(ApplicationDbContext db)
    {
        var user = new User
        {
            Name = "Alice",
            Email = "alice@example.com",
            PasswordHash = "hash",
            Role = Domain.Enums.UserRole.Admin
        };
        db.Users.Add(user);
        db.SaveChanges();
        return user;
    }

    [Fact]
    public async Task Handle_ValidCommand_CreatesBoardAndReturnsDto()
    {
        using var db = CreateDb();
        var user = SeedUser(db);
        var handler = new CreateBoardCommandHandler(db);

        var result = await handler.Handle(
            new CreateBoardCommand("Sprint Board", user.Id),
            CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Value!.Name.Should().Be("Sprint Board");
        result.Value.OwnerId.Should().Be(user.Id);
        result.Value.ColumnCount.Should().Be(0);
        db.Boards.Should().HaveCount(1);
    }

    [Fact]
    public async Task Handle_UnknownUser_ReturnsFailure()
    {
        using var db = CreateDb();
        var handler = new CreateBoardCommandHandler(db);

        var result = await handler.Handle(
            new CreateBoardCommand("Board", Guid.NewGuid()),
            CancellationToken.None);

        result.IsFailure.Should().BeTrue();
    }
}
