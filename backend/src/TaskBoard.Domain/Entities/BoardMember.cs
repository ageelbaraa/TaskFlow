using TaskBoard.Domain.Common;
using TaskBoard.Domain.Enums;

namespace TaskBoard.Domain.Entities;

/// <summary>Join entity representing a user's membership on a specific board.</summary>
public class BoardMember : BaseEntity
{
    /// <summary>Gets or sets the board identifier.</summary>
    public Guid BoardId { get; set; }

    /// <summary>Gets or sets the board navigation property.</summary>
    public Board Board { get; set; } = null!;

    /// <summary>Gets or sets the member's user identifier.</summary>
    public Guid UserId { get; set; }

    /// <summary>Gets or sets the user navigation property.</summary>
    public User User { get; set; } = null!;

    /// <summary>Gets or sets the role this member holds on the board.</summary>
    public UserRole Role { get; set; } = UserRole.Member;
}
