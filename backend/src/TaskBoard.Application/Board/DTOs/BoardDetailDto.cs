using TaskBoard.Application.Columns.DTOs;

namespace TaskBoard.Application.Board.DTOs;

/// <summary>Full board representation including all columns and their cards.</summary>
/// <param name="Id">Board identifier.</param>
/// <param name="Name">Board display name.</param>
/// <param name="OwnerId">Identifier of the owning user.</param>
/// <param name="OwnerName">Display name of the owning user.</param>
/// <param name="Columns">Ordered list of columns with their cards.</param>
public sealed record BoardDetailDto(
    Guid Id,
    string Name,
    Guid OwnerId,
    string OwnerName,
    IReadOnlyList<ColumnDto> Columns);
