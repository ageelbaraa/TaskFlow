// ── Global using aliases for the Application project ─────────────────────────
//
// The Application project has a feature folder named "Board" which creates the
// namespace TaskBoard.Application.Board.  C# resolves unqualified names by
// walking up the enclosing namespace chain BEFORE checking 'using' directives,
// so any file in TaskBoard.Application.* that writes the bare name "Board" would
// match the namespace rather than the domain entity, producing CS0118.
//
// A global using alias has higher priority than both namespace-member lookup and
// ordinary using-namespace directives, so declaring it once here fixes every
// file in the project without touching each handler individually.

global using Board = TaskBoard.Domain.Entities.BoardModel;
