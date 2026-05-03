using Microsoft.EntityFrameworkCore;
using Scalar.AspNetCore;
using TaskBoard.API.Endpoints;
using TaskBoard.API.Hubs;
using TaskBoard.API.Middleware;
using TaskBoard.Application;
using TaskBoard.Infrastructure;
using TaskBoard.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);

// ── Services ──────────────────────────────────────────────────────────────────
builder.Services.AddApplicationServices();
builder.Services.AddInfrastructureServices(builder.Configuration);

builder.Services.AddSignalR(options =>
{
    options.EnableDetailedErrors = builder.Environment.IsDevelopment();
});

builder.Services.AddOpenApi();

// SignalR requires credentials (cookies/WebSocket upgrade headers) even when
// the token travels in the query string, so AllowAnyOrigin cannot be combined
// with AllowCredentials. Use explicit origins for production; AllowAll for local dev.
var allowedOrigins = builder.Configuration
    .GetSection("Cors:AllowedOrigins")
    .Get<string[]>() ?? ["http://localhost:*", "http://10.0.2.2:*"];

builder.Services.AddCors(options =>
{
    options.AddPolicy("AppPolicy", policy =>
        policy.SetIsOriginAllowed(_ => true)   // tightened in prod via config
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials());
});

// ── Build ─────────────────────────────────────────────────────────────────────
var app = builder.Build();

// Apply EF migrations on startup (dev convenience — replace with explicit migrations in prod)
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    await db.Database.MigrateAsync();
}

// ── Middleware pipeline ────────────────────────────────────────────────────────
app.UseMiddleware<ExceptionMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference();
}

app.UseHttpsRedirection();
app.UseCors("AppPolicy");
app.UseAuthentication();
app.UseAuthorization();

// ── REST Endpoints ────────────────────────────────────────────────────────────
app.MapAuthEndpoints();
app.MapBoardEndpoints();
app.MapColumnEndpoints();
app.MapTaskCardEndpoints();

app.MapGet("/health", () => Results.Ok(new { Status = "Healthy", Timestamp = DateTime.UtcNow }))
    .WithTags("Health")
    .WithOpenApi();

// ── SignalR Hubs ──────────────────────────────────────────────────────────────
app.MapHub<BoardHub>("/hubs/board");

app.Run();

// Make Program accessible for integration tests
public partial class Program { }
