using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Moq;
using TaskBoard.Application.TaskCards.Commands.MoveCard;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Domain.Entities;
using TaskBoard.Domain.Enums;
using TaskBoard.Infrastructure.Persistence;
using Xunit;

namespace TaskBoard.Tests.Hubs;

/// <summary>
/// Verifies the command handler logic underlying the BoardHub's MoveCard method.
/// Full hub integration tests (SignalR group broadcasts) require a WebApplication
/// test host and are covered by E2E tests.
/// </summary>
public sealed class BoardHubMoveCardTests
{
    private static ApplicationDbContext CreateDb()
    {
        var opts = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString()).Options;
        return new ApplicationDbContext(opts);
    }

    private static (User owner, Domain.Entities.BoardModel board, Column colA,
        Column colB, TaskCard card1, TaskCard card2) Seed(ApplicationDbContext db)
    {
        var owner = new User
        {
            Name = "Hub User", Email = "hub@test.com",
            PasswordHash = "h", Role = UserRole.Admin
        };
        db.Users.Add(owner);

        var board = new Domain.Entities.BoardModel
            { Name = "Hub Board", OwnerId = owner.Id, Owner = owner };
        db.Boards.Add(board);

        var colA = new Column { Board = board, BoardId = board.Id, Title = "Todo", Order = 0 };
        var colB = new Column { Board = board, BoardId = board.Id, Title = "Done", Order = 1 };
        db.Columns.AddRange(colA, colB);

        var card1 = new TaskCard { Column = colA, ColumnId = colA.Id, Title = "Card 1", Order = 0 };
        var card2 = new TaskCard { Column = colA, ColumnId = colA.Id, Title = "Card 2", Order = 1 };
        db.TaskCards.AddRange(card1, card2);

        db.SaveChanges();
        return (owner, board, colA, colB, card1, card2);
    }

    [Fact]
    public async Task MoveCard_ToNewColumn_BroadcastDataIsCorrect()
    {
        using var db = CreateDb();
        var (owner, _, colA, colB, card1, _) = Seed(db);
        var handler = new MoveCardCommandHandler(db);

        // Simulate what BoardHub.MoveCard does: capture fromColumnId first
        var fromColumnId = await db.TaskCards
            .Where(t => t.Id == card1.Id)
            .Select(t => t.ColumnId)
            .FirstAsync();

        var result = await handler.Handle(
            new MoveCardCommand(card1.Id, colB.Id, 0, owner.Id),
            CancellationToken.None);

        result.IsSuccess.Should().BeTrue();

        // Verify the data the hub would broadcast
        fromColumnId.Should().Be(colA.Id);
        result.Value!.ColumnId.Should().Be(colB.Id);
        result.Value.Order.Should().Be(0);
    }

    [Fact]
    public async Task MoveCard_ReordersSourceColumn_AfterRemoval()
    {
        using var db = CreateDb();
        var (owner, _, colA, colB, card1, card2) = Seed(db);
        var handler = new MoveCardCommandHandler(db);

        // Move card1 out; card2 should become order 0
        await handler.Handle(
            new MoveCardCommand(card1.Id, colB.Id, 0, owner.Id),
            CancellationToken.None);

        var remaining = await db.TaskCards
            .Where(t => t.ColumnId == colA.Id)
            .OrderBy(t => t.Order)
            .ToListAsync();

        remaining.Should().HaveCount(1);
        remaining[0].Id.Should().Be(card2.Id);
        remaining[0].Order.Should().Be(0);
    }

    [Fact]
    public async Task MoveCard_UnauthorisedUser_ReturnsFailure()
    {
        using var db = CreateDb();
        var (_, _, _, colB, card1, _) = Seed(db);
        var handler = new MoveCardCommandHandler(db);

        var result = await handler.Handle(
            new MoveCardCommand(card1.Id, colB.Id, 0, Guid.NewGuid()),
            CancellationToken.None);

        result.IsFailure.Should().BeTrue();
        result.Errors.Should().ContainSingle(e => e.Contains("Access denied"));
    }
}
