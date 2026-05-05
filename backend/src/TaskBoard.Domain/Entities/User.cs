using TaskBoard.Domain.Common;
using TaskBoard.Domain.Enums;

namespace TaskBoard.Domain.Entities;

/// <summary>Represents an authenticated system user with role-based access.</summary>
public class User : BaseEntity
{
    /// <summary>Gets or sets the display name.</summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>Gets or sets the unique email address used for login.</summary>
    public string Email { get; set; } = string.Empty;

    /// <summary>Gets or sets the BCrypt-hashed password. Never expose this in DTOs.</summary>
    public string PasswordHash { get; set; } = string.Empty;

    /// <summary>Gets or sets the user's role determining their permissions.</summary>
    public UserRole Role { get; set; } = UserRole.Member;

    /// <summary>Gets or sets the boards this user owns.</summary>
    public ICollection<BoardModel> OwnedBoards { get; set; } = new List<BoardModel>();

    /// <summary>Gets or sets the board memberships for this user.</summary>
    public ICollection<BoardMember> BoardMemberships { get; set; } = new List<BoardMember>();

    /// <summary>Gets or sets the task cards assigned to this user.</summary>
    public ICollection<TaskCard> AssignedCards { get; set; } = new List<TaskCard>();

    /// <summary>Gets or sets the comments authored by this user.</summary>
    public ICollection<Comment> Comments { get; set; } = new List<Comment>();
}
