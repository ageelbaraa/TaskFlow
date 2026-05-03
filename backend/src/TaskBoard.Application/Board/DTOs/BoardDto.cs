namespace TaskBoard.Application.Board.DTOs;

/// <summary>Summary representation of a board for list views.</summary>
/// <param name="Id">Board identifier.</param>
/// <param name="Name">Board display name.</param>
/// <param name="OwnerId">Identifier of the owning user.</param>
/// <param name="OwnerName">Display name of the owning user.</param>
/// <param name="ColumnCount">Number of columns on the board.</param>
/// <param name="MemberCount">Number of members including the owner.</param>
/// <param name="CreatedAt">UTC creation timestamp.</param>
public sealed record BoardDto(
    Guid Id,
    string Name,
    Guid OwnerId,
    string OwnerName,
    int ColumnCount,
    int MemberCount,
    DateTime CreatedAt);
