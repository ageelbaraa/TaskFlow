using TaskBoard.Application.TaskCards.DTOs;

namespace TaskBoard.Application.Columns.DTOs;

/// <summary>Column representation including its ordered task cards.</summary>
/// <param name="Id">Column identifier.</param>
/// <param name="BoardId">Parent board identifier.</param>
/// <param name="Title">Column header title.</param>
/// <param name="Order">Zero-based display position among sibling columns.</param>
/// <param name="Cards">Ordered task cards in this column.</param>
public sealed record ColumnDto(
    Guid Id,
    Guid BoardId,
    string Title,
    int Order,
    IReadOnlyList<TaskCardDto> Cards);
