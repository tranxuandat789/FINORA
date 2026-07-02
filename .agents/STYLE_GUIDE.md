# UI Coding & Styling Guide (STYLE_GUIDE.md)

This document maps the visual designs and tokens of FINORA to clear coding rules for frontend developers and AI agents. It should be used in conjunction with the comprehensive design document [DESIGN.md](file:///d:/k%C3%AC%208/Prm_Project/FINORA/DESIGN.md).

---

## 1. Design Tokens & Visual Specifications
For specific details on colors, typography, spacing intervals, border radius, and motion curves, refer directly to [DESIGN.md](file:///d:/k%C3%AC%208/Prm_Project/FINORA/DESIGN.md). Do not duplicate those values here.

---

## 2. Spacing & Layout Code Rules
*   **Base Grid Constraint:** All paddings, margins, gaps, and heights must be multiples of **4px** (4, 8, 12, 16, 20, 24, 32, 40, etc.).
*   **Default Page Margins:** Screen roots must use a horizontal padding of exactly **20px** to keep visual elements aligned.
*   **Card Paddings:** Cards must use **16px** or **20px** padding internally.
*   **Spacing Implementation:** Use `SizedBox(width: ...)` and `SizedBox(height: ...)` with multiples of 4 for spacing out items inside Row and Column elements.

---

## 3. Typography Implementation
*   **Google Fonts Configuration:** Google Fonts must have dynamic HTTP fetching disabled at startup (defined in `main.dart` as `GoogleFonts.config.allowRuntimeFetching = false`). Fonts must be bundled locally.
*   **Font Family:** Use Outfit or Inter as defined in the global text theme. Apply custom styles through `Theme.of(context).textTheme`.

---

## 4. Color System & Theme Implementation
*   **Seed Color:** The app uses seed color `0xFF246BFD` for `ColorScheme.fromSeed` to drive Material 3 component colors.
*   **Widget Colors:** Buttons and input highlights are built using Tailwind Blue-600 (`0xFF2563EB`).
*   **Checking Dark/Light State:** Always check the theme context rather than assuming state:
    ```dart
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    ```
*   **Theme Inversion Fixes:** Verify that bottom sheets and alerts support both themes correctly. Do not hardcode white backgrounds (`Colors.white`) or dark text without checking the active theme.

---

## 5. Responsive Design Constraint
*   **Mobile-First Cap:** The application runs inside a mobile viewport width limit. This is configured globally in `main.dart` using a `ConstrainedBox`:
    ```dart
    builder: (context, child) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: child,
        ),
      );
    }
    ```
*   Ensure that all full-width elements dynamically scale within the 430px limit and wrap content to avoid horizontal overflows.

---

## 6. State Management Rules (Provider)
We use the `ChangeNotifier` pattern for feature state management.

### Coding Rules
1.  **Read vs Watch:**
    *   Use `context.read<T>()` inside callback handlers (e.g. `onPressed`). Never use `read` inside `Widget build()`.
    *   Use `context.watch<T>()` or `Consumer<T>` inside `Widget build()` to react to state updates.
2.  **State Modifications:** All calls that modify data must trigger `notifyListeners()`. Expose status parameters (e.g. `isLoading`, `errorMessage`) to let the UI react appropriately.
3.  **Instantiation Safety:** Never call `notifyListeners()` during a provider's initialization or inside its constructor. Use `WidgetsBinding.instance.addPostFrameCallback` if you must trigger an event immediately.
4.  **Decouple UI:** Keep business operations (calculations, JSON parsing, API calls) out of the Screens and Widgets.

---

## 7. Reusable Component Patterns

### Forms & Input Fields
*   Form inputs must support inline validation errors.
*   Password fields must include a visibility toggle suffix icon (`Icons.visibility` and `Icons.visibility_off`) linked to an `obscureText` boolean state.

### SnackBar Alerts
*   Always display notifications using `SnackBarUtils.showTopSnackBar()` to animate alert banners down from the top edge of the screen using a slide transition.

### Modals & Bottom Sheets
*   Bottom sheets must be invoked via `showModalBottomSheet()` with `isScrollControlled: true` and maximum height bounded to 50% of the screen.
*   Include a drag handle at the top edge of the bottom sheet (**40px x 4px** container with rounded corners).
