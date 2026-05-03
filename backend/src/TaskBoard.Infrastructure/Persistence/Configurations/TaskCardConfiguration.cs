using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TaskBoard.Domain.Entities;

namespace TaskBoard.Infrastructure.Persistence.Configurations;

/// <summary>Configures the <see cref="TaskCard"/> entity mapping.</summary>
internal sealed class TaskCardConfiguration : IEntityTypeConfiguration<TaskCard>
{
    /// <inheritdoc />
    public void Configure(EntityTypeBuilder<TaskCard> builder)
    {
        builder.HasKey(t => t.Id);

        builder.Property(t => t.Title)
            .IsRequired()
            .HasMaxLength(300);

        builder.Property(t => t.Description)
            .HasMaxLength(4000);

        builder.Property(t => t.Priority)
            .IsRequired()
            .HasConversion<string>();

        builder.HasMany(t => t.Comments)
            .WithOne(c => c.TaskCard)
            .HasForeignKey(c => c.TaskCardId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
