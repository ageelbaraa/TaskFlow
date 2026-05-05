using Microsoft.EntityFrameworkCore;
using TaskBoard.Domain.Entities;

namespace TaskBoard.Application.Common.Interfaces;

/// <summary>
/// Abstraction over the EF Core DbContext used by application-layer handlers.
/// Keeping handlers decoupled from the concrete DbContext enables in-memory testing.
/// </summary>
public interface IApplicationDbContext
{
    /// <summary>Gets the users set.</summary>
    DbSet<User> Users { get; }

    /// <summary>Gets the boards set.</summary>
    DbSet<BoardModel> Boards { get; }

    /// <summary>Gets the board members set.</summary>
    DbSet<BoardMember> BoardMembers { get; }

    /// <summary>Gets the columns set.</summary>
    DbSet<Column> Columns { get; }

    /// <summary>Gets the task cards set.</summary>
    DbSet<TaskCard> TaskCards { get; }

    /// <summary>Gets the comments set.</summary>
    DbSet<Comment> Comments { get; }

    /// <summary>Persists all pending changes to the backing store.</summary>
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
