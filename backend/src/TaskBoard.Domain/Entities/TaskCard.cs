using TaskBoard.Domain.Common;
using TaskBoard.Domain.Enums;

namespace TaskBoard.Domain.Entities;

/// <summary>Represents a task card that can be moved between columns.</summary>
public class TaskCard : BaseEntity
{
    /// <summary>Gets or sets the column this card currently belongs to.</summary>
    public Guid ColumnId { get; set; }

    /// <summary>Gets or sets the column navigation property.</summary>
    public Column Column { get; set; } = null!;

    /// <summary>Gets or sets the short title displayed on the card face.</summary>
    public string Title { get; set; } = string.Empty;

    /// <summary>Gets or sets the optional long-form description.</summary>
    public string? Description { get; set; }

    /// <summary>Gets or sets the id of the user assigned to this card, if any.</summary>
    public Guid? AssigneeId { get; set; }

    /// <summary>Gets or sets the assignee navigation property.</summary>
    public User? Assignee { get; set; }

    /// <summary>Gets or sets the priority level of this card.</summary>
    public Priority Priority { get; set; } = Priority.Medium;

    /// <summary>Gets or sets the optional due date in UTC.</summary>
    public DateTime? DueDate { get; set; }

    /// <summary>Gets or sets the zero-based display order within its column.</summary>
    public int Order { get; set; }

    /// <summary>Gets or sets the comments on this card.</summary>
    public ICollection<Comment> Comments { get; set; } = new List<Comment>();
}
