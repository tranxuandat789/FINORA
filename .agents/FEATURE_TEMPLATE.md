# Feature Specification Template (FEATURE_TEMPLATE.md)

*Use this template to plan and document a new feature. Copy this structure to design the technical details before writing code. Cross-reference [CLAUDE.md](file:///d:/k%C3%AC%208/Prm_Project/FINORA/CLAUDE.md) for coding style and [ARCHITECTURE.md](file:///d:/k%C3%AC%208/Prm_Project/FINORA/ARCHITECTURE.md) for layer rules.*

---

## 1. Feature Overview
*   **Feature Name:** [e.g. Quản lý Mục tiêu - Goal Management]
*   **Business Goal:** [Describe what value this feature provides to the user]
*   **Target Domain Logic:** [Reference corresponding logic in DOMAIN_BUSINESS_LOGIC.md]

---

## 2. Interface Designs (UI / Screens)
*   **Screens to implement/modify:**
    - `[ScreenName]Screen` (`lib/features/[feature]/screens/[screen_name]_screen.dart`): [Describe layout, default margins, margins, widgets]
*   **UI Components / Custom Widgets:**
    - `[WidgetName]Widget` (`lib/features/[feature]/widgets/[widget_name]_widget.dart`): [Details]

---

## 3. Data Representation (Models)
*   **Frontend Model:** `lib/features/[feature]/models/[name]_model.dart`
    - Class properties, fields.
    - JSON serialization methods (`fromJson`, `toJson`).
*   **Backend Entity:** `backend/Models/[Name].cs`
    - Database entity fields, relations, and table constraints.
*   **Backend DTOs:**
    - `backend/DTOs/Requests/Create[Name]Request.cs`
    - `backend/DTOs/Responses/[Name]Response.cs`

---

## 4. Backend Persistence & Business Logic

### Repositories
*   Interface: `backend/Repositories/Interfaces/I[Name]Repository.cs`
*   Implementation: `backend/Repositories/Implementations/[Name]Repository.cs`
*   Database Queries / Methods: `CRUD operations, special queries`

### Services
*   Interface: `backend/Services/Interfaces/I[Name]Service.cs`
*   Implementation: `backend/Services/Implementations/[Name]Service.cs`
*   Business Rules: `Validation, exception triggers`

### Controllers
*   Controller: `backend/Controllers/[Name]sController.cs`
*   Endpoints:
    - `GET api/[name]s`
    - `POST api/[name]s`
    - `DELETE api/[name]s/{id}`

---

## 5. Frontend Services & State Management (Providers)

### Service Client
*   File: `lib/features/[feature]/services/[name]_service.dart`
*   Methods: `Calls to ApiClient with endpoints`

### State Provider
*   File: `lib/features/[feature]/providers/[name]_provider.dart`
*   State variables: `isLoading`, `items`, `errorMessage`, `isOffline`
*   Offline Fallback logic: `FileStorageService caching and sync queue entries`

---

## 6. Implementation Checklists & Definition of Done

### Phase Checklists
- [ ] Requirements validated against [DOMAIN_BUSINESS_LOGIC.md](file:///d:/k%C3%AC%208/Prm_Project/FINORA/DOMAIN_BUSINESS_LOGIC.md)
- [ ] Database migrations created and applied
- [ ] API endpoints verified with `.http` file
- [ ] Mobile models and services implemented
- [ ] Offline caching and sync queue hooks verified
- [ ] UI built matching spacing and theme guidelines in [STYLE_GUIDE.md](file:///d:/k%C3%AC%208/Prm_Project/FINORA/STYLE_GUIDE.md)

### Verification
*   **Success Condition:** [Describe how the user tests if the feature is 100% working]
