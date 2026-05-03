namespace TaskBoard.Domain.Enums;

/// <summary>Urgency level for a task card.</summary>
public enum Priority
{
    /// <summary>Low urgency, can wait.</summary>
    Low = 0,

    /// <summary>Standard priority.</summary>
    Medium = 1,

    /// <summary>High urgency, needs attention soon.</summary>
    High = 2,

    /// <summary>Critical — must be addressed immediately.</summary>
    Critical = 3
}
