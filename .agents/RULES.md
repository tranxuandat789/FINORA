# FINORA Workspace AI Rules (.agents/RULES.md)

This document contains the 9 core rule groups that govern how all AI agents must behave, think, code, plan, verify, test, communicate, and manage token usage within the **FINORA** project workspace.

---

## 1. Behavior Rules (Most Important)
These rules decide how you, the AI, behave and make decisions:
*   **Never assume missing information:** If any requirement, parameter, or logical rule is ambiguous, stop and ask the user.
*   **Ask clarifying questions:** Prefer asking clarifying questions whenever requirements are unclear.
*   **Never hallucinate:** Do not fabricate APIs, libraries, files, classes, endpoints, database schemas, or business logic.
*   **Acknowledge uncertainty:** If you are uncertain about something, explicitly state your uncertainty instead of guessing.
*   **Never fabricate implementation details:** Do not invent mock structures or logic that do not match the real project state.
*   **Verify before answering:** Double-check your understanding of the existing code and requirements.
*   **Prefer asking over assuming:** It is always better to prompt the user than to make incorrect design/logic decisions.
*   **Think before coding:** Formulate your logic, understand the context, and identify edge cases before proposing changes.

## 2. Scope Rules
These rules prevent scope creep and ensure you do not exceed requirements:
*   **Only work on the requested task:** Focus strictly on what the user asked you to do.
*   **Modify only relevant files:** Do not edit files outside the boundary of the requested task.
*   **Never refactor unrelated code:** Leave unrelated code untouched, even if you see styling or syntax improvements elsewhere, unless specifically requested.
*   **Never introduce new features unless requested:** Do not add unrequested functionality, options, helper utilities, or dependencies.
*   **Keep changes as small as possible:** Implement minimal, incremental, and highly surgical diffs.

## 3. Architecture Rules
These rules ensure that you respect the structural integrity of the project:
*   **Respect existing architecture:** Follow the C# N-Tier architecture on the Backend and the Provider-based Feature structure on the Frontend.
*   **Never replace project architecture:** Do not rewrite architecture patterns. For example, since this project uses Provider for Flutter state management, you **must not** introduce BLoC, Riverpod, or other libraries.
*   **No unapproved design patterns:** Do not introduce new design patterns without explicit approval.
*   **Follow dependency direction:** Strictly adhere to the layers defined in `ARCHITECTURE.md` (e.g., Domain must not import Infrastructure/Controllers).
*   **Preserve module boundaries:** Do not cross-import packages or modules that violate layer boundary constraints.

## 4. Coding Rules
These rules ensure high-quality, readable, and maintainable code:
*   **Follow SOLID principles:** Ensure Single Responsibility, Open-Closed, Liskov Substitution, Interface Segregation, and Dependency Inversion.
*   **Follow Clean Code practices:** Code must be clear, well-structured, and easy to read.
*   **Avoid duplicated code:** Use helper widgets or shared services when appropriate, but do not refactor unrelated classes.
*   **Use meaningful names:** Use descriptive and clear naming conventions following C# and Dart styles defined in `CLAUDE.md`.
*   **Keep functions small:** Deconstruct long functions into small, single-purpose helper methods.
*   **Keep widgets/components reusable:** Design UI parts to be modular and avoid massive widget trees.
*   **Prefer composition over inheritance:** Use composition for widget layout and service integration.

## 5. Planning Rules
These rules prevent writing code prematurely:
*   **Before coding, you must:**
    1.  Understand the requirement completely.
    2.  Identify all affected files and libraries.
    3.  Explain your implementation plan clearly.
    4.  Confirm assumptions with the user.
*   **DO NOT code immediately (Không được code ngay):** You must present a plan and wait for the user to approve it (or outline the plan clearly in your response) before starting to write code.

## 6. Verification Rules
These rules ensure your work is correct before completing the task:
*   **Before completion, you must:**
    1.  Review all generated code.
    2.  Check for compile errors.
    3.  Check imports to make sure no unused or circular dependencies are introduced.
    4.  Check code formatting (runs `dotnet format` or `flutter format` if possible).
    5.  Verify business logic against `DOMAIN_BUSINESS_LOGIC.md`.
    6.  Run existing tests to ensure no regressions are introduced.
*   **DO NOT mark as Done prematurely (AI không được Done ✅ nếu chưa verify):** Never declare success or mark a task as completed without validating the code against these checkpoints.

## 7. Testing Rules
These rules focus on ensuring stability:
*   **Generate unit tests whenever possible:** Write tests for new business logic, service classes, and state providers.
*   **Cover edge cases:** Write tests for null values, empty states, network timeouts, and boundary conditions.
*   **Cover validation:** Write tests to assert correct inputs and error messages for invalid inputs.
*   **Cover error handling:** Verify that exceptions are caught, logged, and surfaced to the UI correctly.
*   **Never skip testing:** If testing is possible in the environment, run the test suite to verify changes.

## 8. Communication Rules
These rules define how you communicate with the user:
*   **Be concise:** Keep your explanations short and focused.
*   **Use markdown:** Format your responses with headers, lists, code blocks, and alerts.
*   **Explain trade-offs:** Always list the performance, complexity, or security trade-offs of your implementation choices.
*   **If multiple solutions exist:**
    *   Present the available options clearly.
    *   Explain the pros and cons of each approach.
    *   Do not choose automatically—ask the user to select their preferred path.

## 9. Token Optimization Rules
These rules save context window space and speed up responses:
*   **Reuse project context:** Avoid reloading large blocks of files.
*   **Reference markdown files:** Refer to specific guides (e.g., `STYLE_GUIDE.md`) by path rather than repeating guidelines in text.
*   **Do not repeat architecture:** Do not explain the project architecture or conventions in every response.
*   **Avoid duplicated explanations:** Provide only new information; do not re-explain what has already been discussed in previous turns.
*   **Use existing documentation:** Leverage the files in `.agents/` as the single source of truth.
*   **Keep responses concise:** Avoid fluff, summaries of obvious code, or generic greetings.
