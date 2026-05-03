using TaskBoard.Domain.Common;

namespace TaskBoard.Domain.Entities;

/// <summary>Represents a comment left by a user on a task card.</summary>
public class Comment : BaseEntity
{
    /// <summary>Gets or sets the parent task card identifier.</summary>
    public Guid TaskCardId { get; set; }

    /// <summary>Gets or sets the parent task card navigation property.</summary>
    public TaskCard TaskCard { get; set; } = null!;

    /// <summary>Gets or sets the author's user identifier.</summary>
    public Guid AuthorId { get; set; }

    /// <summary>Gets or sets the author navigation property.</summary>
    public User Author { get; set; } = null!;

    /// <summary>Gets or sets the markdown body of the comment.</summary>
    public string Body { get; set; } = string.Empty;
}
