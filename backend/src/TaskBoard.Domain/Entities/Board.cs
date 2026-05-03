using TaskBoard.Domain.Common;

namespace TaskBoard.Domain.Entities;

/// <summary>Represents a Kanban board owned by a user and shared with members.</summary>
public class Board : BaseEntity
{
    /// <summary>Gets or sets the display name of the board.</summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>Gets or sets the id of the user who owns this board.</summary>
    public Guid OwnerId { get; set; }

    /// <summary>Gets or sets the owner navigation property.</summary>
    public User Owner { get; set; } = null!;

    /// <summary>Gets or sets the ordered columns on this board.</summary>
    public ICollection<Column> Columns { get; set; } = new List<Column>();

    /// <summary>Gets or sets the member associations for this board.</summary>
    public ICollection<BoardMember> Members { get; set; } = new List<BoardMember>();
}
