# Task Specification Template (TASK_TEMPLATE.md)

*Use this template to define a specific work task or bug fix. Fill in the fields before starting work to align the development scope.*

---

## 1. Context & Objective
*   **Target Feature / Scope:** [e.g., Adding transaction confirmation sound, Fixing dark theme contrast in budget list]
*   **Problem Statement / Goal:** [Brief description of what needs to be solved]

---

## 2. Acceptance Criteria
- [ ] Criterion 1 (e.g. "Dialog should show dark gray background in dark mode")
- [ ] Criterion 2 (e.g. "Pressing cancel closes the dialog without service calls")
- [ ] Criterion 3 (e.g. "Input validates numbers > 0")

---

## 3. Implementation Plan & File Scope

### Files To Modify
*   `[Path/To/File1.dart/cs]`
    - Description of edits (e.g. "Add validator logic to the controller")
*   `[Path/To/File2.dart/cs]`
    - Description of edits (e.g. "Wrap content in Theme-based background")

### Files To Avoid / Protected
*   `[Path/To/File3.dart/cs]`
    - *Reason:* State is shared; do not modify fields here to avoid side-effects.

---

## 4. Testing & Verification

### Unit / Automated Verification
- [ ] Run command: `flutter test test/widget_test.dart` (or other target test)
- [ ] Test endpoints using: `backend/FinanceAPI.http`

### Manual Test Checklist
- [ ] Action 1: Disconnect network, submit transaction. Verify it goes to offline queue.
- [ ] Action 2: Reconnect, trigger sync. Verify database is updated.
- [ ] Action 3: Verify screen looks correct on light and dark mode.
