using TaskBoard.Domain.Common;

namespace TaskBoard.Domain.Entities;

/// <summary>Represents an ordered column (swim lane) within a board.</summary>
public class Column : BaseEntity
{
    /// <summary>Gets or sets the parent board identifier.</summary>
    public Guid BoardId { get; set; }

    /// <summary>Gets or sets the parent board navigation property.</summary>
    public Board Board { get; set; } = null!;

    /// <summary>Gets or sets the column header title.</summary>
    public string Title { get; set; } = string.Empty;

    /// <summary>Gets or sets the zero-based display order among sibling columns.</summary>
    public int Order { get; set; }

    /// <summary>Gets or sets the task cards contained in this column.</summary>
    public ICollection<TaskCard> Cards { get; set; } = new List<TaskCard>();
}
