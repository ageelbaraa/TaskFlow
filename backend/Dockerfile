# ── Stage 1: restore & build ──────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy solution and project files first so layer-caching skips restore
# when only source files change.
COPY TaskBoard.sln .
COPY src/TaskBoard.Domain/TaskBoard.Domain.csproj             src/TaskBoard.Domain/
COPY src/TaskBoard.Application/TaskBoard.Application.csproj   src/TaskBoard.Application/
COPY src/TaskBoard.Infrastructure/TaskBoard.Infrastructure.csproj src/TaskBoard.Infrastructure/
COPY src/TaskBoard.API/TaskBoard.API.csproj                   src/TaskBoard.API/
COPY tests/TaskBoard.Tests/TaskBoard.Tests.csproj             tests/TaskBoard.Tests/

RUN dotnet restore

# Copy everything and publish
COPY . .
RUN dotnet publish src/TaskBoard.API/TaskBoard.API.csproj \
    -c Release \
    -o /app/publish \
    --no-restore

# ── Stage 2: runtime image ────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# Non-root user for security.
# dotnet/aspnet is Debian-based: use groupadd/useradd, not Alpine's addgroup/adduser.
RUN groupadd --system appgroup && useradd --system --gid appgroup appuser
USER appuser

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

EXPOSE 8080

ENTRYPOINT ["dotnet", "TaskBoard.API.dll"]
