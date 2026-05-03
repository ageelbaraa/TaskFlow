using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Comments.Commands.AddComment;
using TaskBoard.Domain.Entities;
using TaskBoard.Domain.Enums;
using TaskBoard.Infrastructure.Persistence;
using Xunit;

namespace TaskBoard.Tests.Comments;

/// <summary>Unit tests for <see cref="AddCommentCommandHandler"/>.</summary>
public sealed class AddCommentCommandHandlerTests
{
    private static ApplicationDbContext CreateDb()
    {
        var opts = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString()).Options;
        return new ApplicationDbContext(opts);
    }

    private static (User owner, Domain.Entities.Board board, Column col, TaskCard card)
        Seed(ApplicationDbContext db)
    {
        var owner = new User
        {
            Name = "Owner", Email = "owner@test.com",
            PasswordHash = "h", Role = UserRole.Admin
        };
        db.Users.Add(owner);

        var board = new Domain.Entities.Board
            { Name = "B", OwnerId = owner.Id, Owner = owner };
        db.Boards.Add(board);

        var col = new Column { Board = board, BoardId = board.Id, Title = "Todo", Order = 0 };
        db.Columns.Add(col);

        var card = new TaskCard
            { Column = col, ColumnId = col.Id, Title = "Fix bug", Order = 0 };
        db.TaskCards.Add(card);

        db.SaveChanges();
        return (owner, board, col, card);
    }

    [Fact]
    public async Task Handle_ValidCommand_PersistsCommentAndReturnsBoardId()
    {
        using var db = CreateDb();
        var (owner, board, col, card) = Seed(db);
        var handler = new AddCommentCommandHandler(db);

        var result = await handler.Handle(
            new AddCommentCommand(card.Id, "Looks good!", owner.Id),
            CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Value!.Body.Should().Be("Looks good!");
        result.Value.AuthorName.Should().Be("Owner");
        result.Value.BoardId.Should().Be(board.Id);
        result.Value.TaskCardId.Should().Be(card.Id);

        db.Comments.Should().HaveCount(1);
    }

    [Fact]
    public async Task Handle_UnknownCard_ReturnsFailure()
    {
        using var db = CreateDb();
        var (owner, _, _, _) = Seed(db);
        var handler = new AddCommentCommandHandler(db);

        var result = await handler.Handle(
            new AddCommentCommand(Guid.NewGuid(), "Comment", owner.Id),
            CancellationToken.None);

        result.IsFailure.Should().BeTrue();
    }

    [Fact]
    public async Task Handle_UnauthorisedUser_ReturnsFailure()
    {
        using var db = CreateDb();
        var (_, _, _, card) = Seed(db);
        var handler = new AddCommentCommandHandler(db);

        var result = await handler.Handle(
            new AddCommentCommand(card.Id, "Sneaky comment", Guid.NewGuid()),
            CancellationToken.None);

        result.IsFailure.Should().BeTrue();
        result.Errors.Should().ContainSingle(e => e.Contains("Access denied"));
    }
}
