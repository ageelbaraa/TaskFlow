using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.TaskCards.Commands.MoveCard;
using TaskBoard.Domain.Entities;
using TaskBoard.Domain.Enums;
using TaskBoard.Infrastructure.Persistence;
using Xunit;

namespace TaskBoard.Tests.Board;

/// <summary>Unit tests for <see cref="MoveCardCommandHandler"/>.</summary>
public sealed class MoveCardCommandHandlerTests
{
    private static ApplicationDbContext CreateDb()
    {
        var opts = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString()).Options;
        return new ApplicationDbContext(opts);
    }

    private static (User owner, Domain.Entities.Board board,
        Column colA, Column colB, TaskCard card) Seed(ApplicationDbContext db)
    {
        var owner = new User { Name = "O", Email = "o@e.com", PasswordHash = "h", Role = UserRole.Admin };
        db.Users.Add(owner);

        var board = new Domain.Entities.Board { Name = "B", OwnerId = owner.Id, Owner = owner };
        db.Boards.Add(board);

        var colA = new Column { Board = board, BoardId = board.Id, Title = "Todo", Order = 0 };
        var colB = new Column { Board = board, BoardId = board.Id, Title = "Done", Order = 1 };
        db.Columns.AddRange(colA, colB);

        var card = new TaskCard { Column = colA, ColumnId = colA.Id, Title = "T1", Order = 0 };
        db.TaskCards.Add(card);

        db.SaveChanges();
        return (owner, board, colA, colB, card);
    }

    [Fact]
    public async Task Handle_MoveToDifferentColumn_UpdatesColumnAndOrder()
    {
        using var db = CreateDb();
        var (owner, _, _, colB, card) = Seed(db);
        var handler = new MoveCardCommandHandler(db);

        var result = await handler.Handle(
            new MoveCardCommand(card.Id, colB.Id, 0, owner.Id),
            CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Value!.ColumnId.Should().Be(colB.Id);
        result.Value.Order.Should().Be(0);
    }

    [Fact]
    public async Task Handle_MoveToNonExistentColumn_ReturnsFailure()
    {
        using var db = CreateDb();
        var (owner, _, _, _, card) = Seed(db);
        var handler = new MoveCardCommandHandler(db);

        var result = await handler.Handle(
            new MoveCardCommand(card.Id, Guid.NewGuid(), 0, owner.Id),
            CancellationToken.None);

        result.IsFailure.Should().BeTrue();
    }
}
