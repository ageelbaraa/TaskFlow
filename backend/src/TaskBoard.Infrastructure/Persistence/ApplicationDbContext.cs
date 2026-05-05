using Microsoft.EntityFrameworkCore;
using TaskBoard.Application.Common.Interfaces;
using TaskBoard.Domain.Entities;

namespace TaskBoard.Infrastructure.Persistence;

/// <summary>
/// EF Core DbContext for the TaskBoard application.
/// Implements <see cref="IApplicationDbContext"/> so application handlers
/// remain unaware of the concrete EF type.
/// </summary>
public class ApplicationDbContext : DbContext, IApplicationDbContext
{
    /// <summary>Initializes the context with the supplied options.</summary>
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options) { }

    /// <inheritdoc />
    public DbSet<User> Users => Set<User>();

    /// <inheritdoc />
    public DbSet<BoardModel> Boards => Set<BoardModel>();

    /// <inheritdoc />
    public DbSet<BoardMember> BoardMembers => Set<BoardMember>();

    /// <inheritdoc />
    public DbSet<Column> Columns => Set<Column>();

    /// <inheritdoc />
    public DbSet<TaskCard> TaskCards => Set<TaskCard>();

    /// <inheritdoc />
    public DbSet<Comment> Comments => Set<Comment>();

    /// <inheritdoc />
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
        base.OnModelCreating(modelBuilder);
    }

    /// <summary>
    /// Automatically stamps <c>UpdatedAt</c> on modified entities before saving.
    /// </summary>
    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        foreach (var entry in ChangeTracker.Entries<Domain.Common.BaseEntity>())
        {
            if (entry.State == EntityState.Modified)
                entry.Entity.UpdatedAt = DateTime.UtcNow;
        }

        return base.SaveChangesAsync(cancellationToken);
    }
}
