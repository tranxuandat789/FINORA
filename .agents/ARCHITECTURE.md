# Architectural Specification (ARCHITECTURE.md)

This document specifies the architecture, folder layout, dependency flows, and import boundaries of the **FINORA** project. All developers and AI agents must strictly adhere to these rules.

---

## 1. System Overview
FINORA uses a client-server architecture. All operations are centralized via an online API, but the client features a local file storage caching system that permits resilient offline access.

```
┌────────────────────────────────────────────────────────┐
│                   Flutter Mobile Client                │
│  (UI Screens & Widgets ──> Providers ──> Services)    │
└───────────────────────────┬────────────────────────────┘
                            │ (JSON over HTTP/HTTPS)
                            ▼
┌────────────────────────────────────────────────────────┐
│                   ASP.NET Web API Server                │
│  (Controllers ──> Services ──> Repositories ──> DB)    │
└────────────────────────────────────────────────────────┘
```

---

## 2. Backend Architecture (ASP.NET Core)
The backend is structured as an **N-Tier Monolith** within a single assembly project (`FinanceAPI`).

### Technical Directory Structure & Responsibilities
*   **`Data/`:** Contains database access contexts (`AppDbContext.cs`).
*   **`Models/`:** Houses the persistence database entities (e.g., `User.cs`, `Transaction.cs`). These map directly to SQL Server tables via Entity Framework Core.
*   **`DTOs/`:** Stores Request and Response models.
    *   *Rule:* Entities must never be returned to or received from the API endpoints. Use DTOs instead.
*   **`Repositories/`:** Contains interface definitions (`Interfaces/`) and concrete SQL queries/EF code (`Implementations/`).
    *   *Rule:* Only Repositories may access the DB contexts or database objects.
*   **`Services/`:** Contains business logic and integration code (e.g., wallet arithmetic, password checking, email sending).
    *   *Interfaces/*: Public service definitions.
    *   *Implementations/*: Concrete class files.
*   **`Controllers/`:** Exposes REST API endpoints. They parse incoming requests, authorize tokens, trigger services, and return unified `ApiResponse<T>` objects.
*   **`Middlewares/`:** Custom ASP.NET request handlers (e.g., `ExceptionHandlingMiddleware` for global try-catch mappings).
*   **`Configurations/` & `Helpers/`:** Holds static configuration extensions, constants, and utilities.

### Backend Dependency Flow
The dependencies must flow one-way from the boundary (API) down to the storage (DB). Direct shortcuts that bypass layers are prohibited.

```
[HTTP Client] ──> Controllers ──> Services (Interfaces) ──> Repositories (Interfaces) ──> DB Context
```

*   **Allowed Dependencies:**
    *   Controllers can depend on and inject Services (`ISomethingService`).
    *   Services can depend on other Services or Repositories (`ISomethingRepository`).
    *   Repositories can depend on `AppDbContext`.
*   **Prohibited Dependencies:**
    *   Controllers must never directly instantiate or reference database context (`AppDbContext`).
    *   Controllers must never directly reference Repositories.
    *   Repositories must never reference Services or Controllers.
    *   Database entities must never cross the Controller layer.

---

## 3. Frontend Architecture (Flutter)
The frontend uses a **Feature-Based Architecture** layout combined with the `ChangeNotifier` / `Provider` state management pattern.

### Technical Directory Structure & Responsibilities
*   **`lib/core/`:** Core configurations and shared utilities that cross feature boundaries.
    *   `network/`: Global client client configurations (`api_client.dart` wrapping Dio).
    *   `local_storage/`: Custom local storage helpers (`file_storage_service.dart` wrapping `path_provider`).
    *   `themes/`: Global application themes and configuration files.
    *   `routes/`: App routing and screen navigation definitions.
    *   `providers/`: App-wide states (e.g., `ThemeProvider`).
    *   `utils/`: Core utilities (e.g., `snackbar_utils.dart`).
*   **`lib/features/<feature_name>/`:** Encapsulated domain components.
    *   `models/`: Parse network data (e.g., `transaction_model.dart` with `fromJson`/`toJson`).
    *   `services/`: Communicate with the API via the global `ApiClient`.
    *   `providers/`: Hold UI state, trigger Services, and manage local JSON caches when operations fail.
    *   `screens/`: Hold layout and structural widgets.
    *   `widgets/`: Sub-components specific to the feature.
*   **`lib/shared/`:** Shared layout widgets (`shared/widgets/`) or cross-cutting data models (`shared/models/`).

### Frontend Dependency Flow
```
[UI Screen/Widget] ──> Provider ──> Service ──> ApiClient (Network)
                                    └──> FileStorageService (Local Storage)
```

*   **Allowed Imports & Dependencies:**
    *   Screens/Widgets watch or read state using `Provider` (e.g. `context.watch<TransactionProvider>()`).
    *   Providers depend on Services for network actions and `FileStorageService` for reading/writing caches.
    *   Services depend on the shared `ApiClient` to call backend endpoints.
*   **Prohibited Imports & Dependencies:**
    *   Widgets must never directly trigger or instantiate Services or HTTP clients.
    *   Widgets must never do file read/write operations.
    *   Feature services must never import code or classes from another feature's internal directories. Cross-feature communication must happen strictly via Providers at the root level or shared core folders.
    *   Do not use local databases like SQLite or Hive. Offline persistence must strictly use the JSON-file-based caching mechanism.
