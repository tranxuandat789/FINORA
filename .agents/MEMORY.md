# Project Memory Log (.agents/MEMORY.md)

This file tracks the long-term design, technical, and architectural decisions of the **FINORA** project. 

> [!IMPORTANT]
> **Append-Only Rule:** Never overwrite, delete, or modify historical decisions. Always append new decisions or amendments chronologically at the bottom of this file.

---

## 1. Project Inception & Philosophy (2026-07-02)

*   **Pure Manual Finance Tracking:** FINORA does not support automatic bank API linking. All data entry is either fully manual via form input or initiated via manual voice recordings (Push-To-Talk).
*   **Database-Driven Budget Rollover:** Budgets are calculated dynamically at the backend query level. No cron-jobs or background synchronization workers are used to transition budget balances. The backend calculates rollover by aggregating transactions from the budget's `StartDate` to the requested viewing date.
*   **Manual Transfer Representation:** The system does not support a distinct "Transfer" transaction type. Transfers between wallets are modeled by creating two independent transactions: a Chi (Expense) from the origin wallet, and a Thu (Income) into the destination wallet.
*   **Single Currency Support:** The app operates exclusively in Vietnamese Dong (VND).
*   **Flat Categories:** Expense and Income categories are flat. The system does not support sub-categories.

---

## 2. Technical Stack & State Decisions (2026-07-02)

*   **Backend Architecture:** ASP.NET Core Web API following an N-Tier monolithic layout (Controllers -> Services -> Repositories -> DbContext). 
*   **Backend Database Access:** Entity Framework Core (EF Core) targeting Microsoft SQL Server. All database queries must be parameterized to prevent SQL injection.
*   **Backend Security:** Password hashing is powered by BCrypt via ASP.NET Identity's `PasswordHasher<User>`.
*   **Frontend Architecture:** Flutter mobile app grouped by features inside `lib/features/<feature_name>/` containing local models, services, providers, screens, and widgets.
*   **Frontend State Management:** Provider (`MultiProvider` / `ChangeNotifier`) is used exclusively for state management. State mutations must trigger `notifyListeners()`. 
*   **Frontend Local Storage:** Local caching is handled by writing JSON files directly to disk using `path_provider` (via `FileStorageService`). This prevents SQLite/Hive database locks and schema migration overhead on the client.
*   **Frontend Layout Constraint:** The mobile app layout is wrapped in a `ConstrainedBox` limiting the maximum viewport width to **430px** to ensure design consistency across desktop and tablet debugging devices.
*   **Custom Paintings:** The dashboard uses canvas-drawn `CustomPainter` rules and the `fl_chart` library to optimize performance and prevent heavy widget hierarchy redraw issues.

---

## 3. Workspace AI Rules Engine (2026-07-02)

*   **Rules Consolidation:** Created a dedicated rulebook at `.agents/RULES.md` comprising 9 distinct rule groups: Behavior, Scope, Architecture, Coding, Planning, Verification, Testing, Communication, and Token Optimization.
*   **CLAUDE.md Mandate:** Positioned a critical instructions block at the very top of `CLAUDE.md` to force all incoming AI agents to load and follow these rules.
*   **Verification Checkpoints:** AI agents are forbidden from marking tasks as completed or answering before going through explicit verification checks (compile, imports, formatting, and business logic verification).
*   **Planning Constraint:** AI agents must propose and agree on a technical plan (affected files, assumptions, implementation stages) before writing any application code ("Không được code ngay").

