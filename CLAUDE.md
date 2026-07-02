# Global AI Rules & Coding Guidelines (CLAUDE.md)

This document is the Single Source of Truth for all AI agents and developers working on **FINORA**. It defines the workspace standards, tech stack, coding rules, and AI behaviors required to maintain consistency, safety, and token efficiency.

> [!IMPORTANT]
> **MANDATORY RULES DIRECTIVE:**
> You **MUST** read, understand, and strictly follow the 9 core rule groups defined in [`.agents/RULES.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/RULES.md) before making any code modifications, plans, or decisions.
> Confirm compliance with these rules in your very first response of a session.

---

## 1. Project Overview & Tech Stack
**FINORA** is a personal finance management app designed for manual tracking, voice input (PTT), rollover budgeting, and saving goals tracking.

### Technology Stack
*   **Backend:** ASP.NET Core Web API (N-Tier Monolith) using .NET 8+.
    *   *Database:* SQL Server via Entity Framework Core (EF Core).
    *   *Authentication:* JWT Authentication (Custom custom-coded flows).
    *   *Validation:* FluentValidation.
    *   *Docs:* Scalar OpenAPI.
*   **Frontend:** Flutter Mobile App (Mobile-first, constrained to a maximum width of 430px).
    *   *State Management:* Provider (`MultiProvider` / `ChangeNotifier`).
    *   *Network:* Dio (Client-side communication).
    *   *Caching:* Path Provider (File system-based JSON local caching instead of SQLite/Hive).
    *   *Visuals/Charts:* `fl_chart` library and `CustomPainter` canvas routines.
    *   *Voice Input:* `speech_to_text` (PTT voice processing).

---

## 2. Global AI Behavior Rules
All AI agents must strictly follow the comprehensive guidelines defined in [`.agents/RULES.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/RULES.md). Below is a summary of the 9 core rule groups you must adhere to:
1.  **Behavior:** Never assume; ask clarifying questions; never hallucinate; verify before answering; think before coding.
2.  **Scope:** Focus only on the requested task; modify only relevant files; never refactor unrelated code.
3.  **Architecture:** Respect existing patterns (Provider, N-Tier C#); never replace architecture; preserve boundaries.
4.  **Coding:** Follow SOLID principles; use meaningful names; keep functions small; keep widgets reusable.
5.  **Planning:** Plan before coding (Understand, Identify affected files, Explain plan, Confirm assumptions). **DO NOT code immediately (Không được code ngay).**
6.  **Verification:** Review code, check compile/imports/formatting/business logic. **DO NOT mark Done ✅ without verifying.**
7.  **Testing:** Generate unit tests for edge cases, validations, and error handling.
8.  **Communication:** Be concise; explain trade-offs; present options with pros and cons (do not choose automatically).
9.  **Token Optimization:** Reuse context; lazy-load specialized markdown files; avoid redundancy.

---

## 3. Architecture & SOLID Principles
We strictly follow Clean Architecture and SOLID design guidelines:
1.  **Single Responsibility Principle (SRP):**
    *   *Frontend:* UI Widgets only build layout. Services handle HTTP calls. Providers manage state and local caching.
    *   *Backend:* Controllers route/verify. Services handle business logic. Repositories handle database persistence.
2.  **Dependency Inversion Principle (DIP):**
    *   *Frontend:* Providers depend on Service abstractions or concrete service clients registered via Dependency Injection or provider setups.
    *   *Backend:* Controllers depend on `IService` interfaces. Services depend on `IRepository` interfaces. All dependencies must be injected via constructors.
3.  **Entity-DTO Separation:** Backend controllers must never expose database entities. Always use DTOs (Data Transfer Objects) for requests and responses.

---

## 4. Coding & Naming Conventions

### General Naming Patterns
*   **C# (Backend):** PascalCase for classes, interfaces (`I...`), methods, and properties. camelCase for parameters and local variables. `_camelCase` for private fields.
*   **Dart (Frontend):** PascalCase for classes and enums. camelCase for variables, methods, and parameters. `_camelCase` for private variables/methods. snake_case for folder names and filenames.

### File Name Suffixes
| Layer | Backend (C#) | Frontend (Dart) |
|---|---|---|
| Entity / Model | `[Name].cs` (Entity) | `[name]_model.dart` |
| Requests / Responses | `[Name]Request.cs` / `[Name]Response.cs` | (Defined in models or inline) |
| Persistence | `I[Name]Repository.cs` / `[Name]Repository.cs` | (Handled by Services) |
| Business Logic | `I[Name]Service.cs` / `[Name]Service.cs` | `[name]_service.dart` |
| Controller / State | `[Name]Controller.cs` | `[name]_provider.dart` |
| Screens / Widgets | N/A | `[name]_screen.dart` / `[name]_widget.dart` |

---

## 5. Folder Conventions
*   **Backend:** Grouped by technical layers:
    *   `Controllers/`, `Services/`, `Repositories/`, `Data/`, `Models/`, `DTOs/`, `Middlewares/`, `Configurations/`, `Helpers/`
*   **Frontend:** Grouped by features (`lib/features/<feature_name>/`):
    *   Subfolders per feature: `models/`, `services/`, `providers/`, `screens/`, `widgets/`
    *   Global code: `lib/core/` (`network/`, `local_storage/`, `providers/`, `routes/`, `themes/`, `utils/`)

For a detailed walkthrough of directory layout, refer to [ARCHITECTURE.md](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/ARCHITECTURE.md).

---

## 6. Error Handling & Logging

### Backend (ASP.NET Core)
*   **Global Exception Handling:** Handled via `ExceptionHandlingMiddleware`, formatting errors into a unified `ApiResponse<object>.Fail(message)` structure.
*   **Action Filters / Catch Blocks:** Custom endpoint logic uses try-catch, converting specific business exceptions to bad requests while allowing system failures to bubble up to the global middleware.
*   **Logging:** Use `ILogger<T>` inside classes. Log warning/error events with context data. Never log plain passwords or sensitive tokens.

### Frontend (Flutter)
*   **API Failures:** Caught in `services/`. Throw custom exceptions indicating connection issues or validation failures.
*   **State-Level Resilience:** Providers catch service exceptions. If offline, they load data from JSON files via `FileStorageService` and enqueue mutations in the sync queue.
*   **Feedback:** User notifications are shown via `SnackBarUtils.showTopSnackBar()`.

---

## 7. Testing & Quality Strategy
*   **Backend:** API endpoints can be tested via the root `.http` files (e.g., `FinanceAPI.http`).
*   **Frontend:** Widget and unit tests are stored in the `test/` directory (e.g., `widget_test.dart`). Keep test coverage up-to-date for state transitions.

---

## 8. Security & Performance

### Security
*   Password hashing must use `BCrypt` (via Identity's `PasswordHasher<User>`).
*   JWT authentication must validate signatures and set lifetime constraints with zero clock skew.
*   Sanitize database queries using Entity Framework parameterized queries (no raw SQL injection).

### Performance
*   **Device Width Constraints:** Limit MaterialApp root body width to `430px` to maintain layouts across screens.
*   **JSON Local Storage:** Save/load local data in short JSON files. Do not use local SQLite or Hive databases to prevent file locks.
*   **Visual Optimization:** Use canvas-drawn custom painters for dashboards instead of heavy libraries to maintain 60 FPS scrolling.

---

## 9. Token Optimization & Documentation Guide
To minimize context size and prevent hallucinations, reference the specialized files in the `.agents/` folder:
*   For the 9 core AI rule groups governing behavior, scope, and planning, check [RULES.md](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/RULES.md).
*   For the master document list and routing map, check the [Agent Routing Guide](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/README.md).
*   For standard pipelines and checklists, check [PIPELINE.md](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/PIPELINE.md).
*   For layer boundaries and allowed imports, check [ARCHITECTURE.md](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/ARCHITECTURE.md).
*   For UI guidelines and state rules, check [STYLE_GUIDE.md](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/STYLE_GUIDE.md) and [DESIGN.md](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/DESIGN.md).
*   For core business logic and database rules, check [DOMAIN_BUSINESS_LOGIC.md](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/DOMAIN_BUSINESS_LOGIC.md).
*   For historical architecture decisions and limitations, check [MEMORY.md](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/MEMORY.md).
*   Use [FEATURE_TEMPLATE.md](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/FEATURE_TEMPLATE.md) and [TASK_TEMPLATE.md](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/TASK_TEMPLATE.md) to structure your work.
