namespace TaskBoard.Domain.Enums;

/// <summary>Defines the access level of a user within the system.</summary>
public enum UserRole
{
    /// <summary>Can manage boards, columns, cards, members, and settings.</summary>
    Admin = 0,

    /// <summary>Can create, move, and comment on cards within boards they belong to.</summary>
    Member = 1,

    /// <summary>Read-only access; cannot modify any board data.</summary>
    Viewer = 2
}
