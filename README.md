# FINORA - Personal Finance Tracking App

FINORA is a manual personal finance tracking application designed for smart budget management, voice-activated expense logging, rollover budgets, and savings goals tracking.

---

## 📂 Repository Structure

*   **`backend/`**: ASP.NET Core Web API (.NET 8+) monolithic server implementing business logic, Entity Framework Core queries, global error handling, and Scalar OpenAPI.
*   **`mobile/`**: Flutter mobile application using the Provider state management pattern, Dio client networking, custom-painter canvas charts, and local file storage JSON caching.
*   **`database/`**: SQL Server local databases schemas and migration scripts.
*   **`.agents/`**: Core AI Knowledge Base, containing architectural specifications, UI coding/styling guidelines, business domain rules, pipelines, and templates.

---

## 🤖 AI Agent & Developer Onboarding

This project contains a dedicated knowledge base for developers and AI agents (such as Cursor, Windsurf, Claude Code, and Gemini):

1.  **Global Instructions:** Read [`CLAUDE.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/CLAUDE.md) at the root first for AI behavior rules, coding standards, naming conventions, and constraints.
2.  **Specialized Knowledge:** Open [`.agents/README.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/README.md) (the Agent Routing Guide) to find specialized files on:
    *   Workspace AI Rules & Behaviors ([`RULES.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/RULES.md))
    *   System Architecture ([`ARCHITECTURE.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/ARCHITECTURE.md))
    *   UI / Spacing Styling Rules ([`STYLE_GUIDE.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/STYLE_GUIDE.md) & [`DESIGN.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/DESIGN.md))
    *   Business & Rollover Logic ([`DOMAIN_BUSINESS_LOGIC.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/DOMAIN_BUSINESS_LOGIC.md))
    *   Development Pipeline Phases ([`PIPELINE.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/PIPELINE.md))
    *   Historical Architectural Decisions ([`MEMORY.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/MEMORY.md))

---

## 🚀 How to Run

### 1. ASP.NET Core Web API Backend
Ensure you have .NET 8 SDK installed and a running SQL Server instance.
```bash
cd backend
dotnet restore
dotnet run
```

### 2. Flutter Mobile Frontend
Ensure Flutter SDK is set up and an emulator/device is connected.
```bash
cd mobile
flutter pub get
flutter run
```
*(Note: The mobile screen is constrained to a maximum width of 430px as defined in the layout specifications).*
