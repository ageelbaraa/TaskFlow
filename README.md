# ⚡ TaskFlow — Real-Time Team Task Board

> A production-ready Kanban board where every move, comment, and update syncs instantly across all connected clients — built with **.NET 10** and **Flutter**.

---

## 🌐 Live Demo

| Platform | Link |
|----------|------|
| Web (Flutter) | `https://taskflow.demo.app` |
| API Docs (Swagger) | `https://api.taskflow.demo.app/swagger` |

---

## ✨ What Makes This Different

Most task boards fake real-time with polling. **TaskFlow uses SignalR WebSockets** — every card move, comment, and status change is broadcast to all board members in under 50ms.

- **One codebase → three platforms**: Flutter runs on Web, iOS, and Android from the same code
- **Live presence**: see exactly who's online and which card they're viewing
- **Offline-first mobile**: Drift local DB keeps the app functional without a connection
- **Role-based access**: Admin / Member / Viewer — not an afterthought, baked into the domain

---

## 🗂 Project Structure

```
task-board/
│
├── 📁 backend/
│   └── src/
│       ├── TaskBoard.API/              # .NET 10 Minimal APIs + SignalR Hubs
│       │   ├── Endpoints/              # Auth, Boards, Tasks, Comments
│       │   ├── Hubs/
│       │   │   └── BoardHub.cs         # Real-time WebSocket hub
│       │   ├── Middleware/             # Global error handler, JWT validation
│       │   └── Program.cs
│       │
│       ├── TaskBoard.Application/      # CQRS — Commands, Queries, Handlers
│       │   ├── Boards/
│       │   ├── Tasks/
│       │   ├── Auth/
│       │   └── Comments/
│       │
│       ├── TaskBoard.Domain/           # Core business logic — pure C#
│       │   ├── Entities/               # User, Board, Column, TaskCard, Comment
│       │   ├── ValueObjects/
│       │   ├── Events/                 # Domain events (CardMoved, CommentAdded)
│       │   └── Enums/                  # Priority, Role, CardStatus
│       │
│       └── TaskBoard.Infrastructure/   # EF Core, Redis, Repositories
│           ├── Persistence/
│           │   ├── AppDbContext.cs
│           │   └── Migrations/
│           ├── Repositories/
│           └── Redis/                  # Presence tracking, pub/sub
│
├── 📁 mobile/                          # Flutter — Web + iOS + Android
│   └── lib/
│       ├── core/
│       │   ├── di/                     # Dependency injection (get_it)
│       │   ├── router/                 # GoRouter navigation
│       │   ├── theme/                  # App theme, colors, typography
│       │   └── network/               # API client, SignalR connection
│       │
│       └── features/
│           ├── auth/                   # Login, register, JWT storage
│           │   ├── bloc/
│           │   ├── data/
│           │   └── presentation/
│           ├── board/                  # Kanban UI + real-time sync
│           │   ├── bloc/
│           │   ├── data/
│           │   └── presentation/
│           ├── tasks/                  # Task detail, comments, assign
│           │   ├── bloc/
│           │   ├── data/
│           │   └── presentation/
│           └── members/               # Team management, roles
│
├── 📁 infra/
│   ├── docker-compose.yml
│   ├── nginx.conf
│   └── .github/
│       └── workflows/
│           ├── backend-ci.yml
│           └── flutter-ci.yml
│
└── README.md
```

---

## 🏗 Architecture

### Backend — Clean Architecture

```
Request → Minimal API Endpoint
       → MediatR Command/Query
       → Application Handler (FluentValidation)
       → Domain Logic
       → Infrastructure (EF Core / Redis)
       → SignalR Broadcast to all board members
```

### SignalR Hub Contract

**Server → Client events**

| Event | Payload |
|-------|---------|
| `CardMoved` | `cardId, fromColumnId, toColumnId, newOrder` |
| `CardUpdated` | `cardId, updatedFields` |
| `CommentAdded` | `taskId, comment` |
| `UserJoined` | `userId, boardId, avatarUrl` |
| `UserLeft` | `userId, boardId` |

**Client → Server methods**

| Method | Payload |
|--------|---------|
| `JoinBoard` | `boardId` |
| `MoveCard` | `cardId, toColumnId, newOrder` |
| `LeaveBoard` | `boardId` |

### Flutter — BLoC Pattern

```
UI Widget
  → fires Event via BLoC
  → Repository (abstract)
    → Remote: API + SignalR client
    → Local:  Drift DB (offline fallback)
  → emits State back to UI
```

---

## 🧱 Domain Entities

| Entity | Key Fields |
|--------|------------|
| `User` | Id, Name, Email, PasswordHash, Role |
| `Board` | Id, Name, OwnerId, Members[] |
| `Column` | Id, BoardId, Title, Order |
| `TaskCard` | Id, ColumnId, Title, AssigneeId, Priority, DueDate, Order |
| `Comment` | Id, TaskCardId, AuthorId, Body, CreatedAt |

### Roles

| Role | Can Do |
|------|--------|
| **Admin** | Create/delete boards, manage members, full task control |
| **Member** | Create, edit, move tasks, add comments |
| **Viewer** | Read-only — see board and task details |

---

## 🚀 Tech Stack

### Backend
| Layer | Technology |
|-------|-----------|
| Runtime | .NET 10 |
| API | Minimal APIs |
| Real-time | ASP.NET Core SignalR |
| Architecture | Clean Architecture + CQRS (MediatR) |
| Validation | FluentValidation |
| Auth | JWT Bearer |
| ORM | Entity Framework Core 9 |
| Database | PostgreSQL |
| Cache / Presence | Redis |

### Frontend
| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| State | BLoC pattern |
| Navigation | GoRouter |
| Real-time | SignalR Dart client |
| Local DB | Drift |
| Secure storage | flutter_secure_storage |

### Infrastructure
| Tool | Purpose |
|------|---------|
| Docker + Compose | Local dev environment |
| Nginx | Reverse proxy + SSL termination |
| GitHub Actions | CI/CD — build, test, deploy |

---

## ⚙️ Getting Started

### Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [Flutter 3.x](https://flutter.dev/docs/get-started/install)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)

### 1. Start infrastructure

```bash
cd infra
docker-compose up -d
# Starts: PostgreSQL + Redis + Nginx
```

### 2. Run the backend

```bash
cd backend/src/TaskBoard.API
dotnet run
# API running at https://localhost:5001
# Swagger at  https://localhost:5001/swagger
```

### 3. Apply database migrations

```bash
cd backend/src/TaskBoard.Infrastructure
dotnet ef database update
```

### 4. Run the Flutter app

```bash
cd mobile
flutter pub get
flutter run -d chrome          # Web
flutter run -d ios             # iOS simulator
flutter run -d android         # Android emulator
```

---

## 🔐 Environment Variables

Create `backend/src/TaskBoard.API/appsettings.Development.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=taskboard;Username=postgres;Password=postgres",
    "Redis": "localhost:6379"
  },
  "Jwt": {
    "Key": "your-super-secret-key-min-32-chars",
    "Issuer": "taskboard-api",
    "Audience": "taskboard-client",
    "ExpiryMinutes": 60
  }
}
```

---

## 🧪 Testing

```bash
# Backend unit tests
cd backend
dotnet test tests/TaskBoard.UnitTests

# Backend integration tests (requires Docker)
dotnet test tests/TaskBoard.IntegrationTests

# Flutter tests
cd mobile
flutter test
```

---

## 🛣 Build Phases

- [x] **Phase 1** — Auth foundation (JWT, login, register)
- [x] **Phase 2** — Board CRUD (columns, cards, REST API)
- [x] **Phase 3** — SignalR real-time layer
- [x] **Phase 4** — Presence tracking + comments
- [ ] **Phase 5** — DevOps (Docker, CI/CD, Nginx)

---

## 📸 Screenshots

> Coming soon — demo GIF showing live card sync across two browser windows.

---

## 🤝 Contributing

1. Fork the repo
2. Create your branch: `git checkout -b feature/your-feature`
3. Commit: `git commit -m 'feat: add your feature'`
4. Push: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

## 👤 Author

**Your Name**
Team Lead & System Architect | .NET & Flutter Expert

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=flat&logo=linkedin)](https://linkedin.com/in/yourprofile)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black?style=flat&logo=github)](https://github.com/yourusername)

---

> *Built to demonstrate real-world system architecture — not just a CRUD app.*
