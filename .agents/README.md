# FINORA Agent Routing Guide (.agents/README.md)

Welcome Agent! This directory serves as the centralized **AI Knowledge Base** for the **FINORA** project. 

Before starting any development, refactoring, or debugging task, refer to the document routing map below to find the specific files containing the context you need. This helps minimize prompt/context size and reduces hallucinations.

---

## Document Routing Map

| Your Task / Goal | File to Read | Purpose / Main Content |
| :--- | :--- | :--- |
| **All Tasks (Start Here)** | `../CLAUDE.md` | Global AI behavior rules, tech stack overview, naming conventions, and core instructions. |
| **Understand AI Behavior & Rules** | [`RULES.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/RULES.md) | The 9 core rules defining how to behave, scope, code, plan, verify, test, communicate, and optimize tokens. |
| **Understand System Architecture** | [`ARCHITECTURE.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/ARCHITECTURE.md) | Backend (C# N-Tier) and Frontend (Flutter Feature-Based) layer layouts, allowed/forbidden dependency maps, and import rules. |
| **Implement UI/UX Designs** | [`DESIGN.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/DESIGN.md) | Detailed UI/UX design specifications, color codes, typography, responsiveness constraints, and WCAG 2.2 accessibility parameters (in Vietnamese). |
| **Check UI Styling & Widget Rules** | [`STYLE_GUIDE.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/STYLE_GUIDE.md) | Coding conventions for Flutter widgets, 4px grid rules, MaterialApp 430px limit, dark/light theme checks, SnackBar utility usage, and Provider guidelines. |
| **Verify Financial Business Logic** | [`DOMAIN_BUSINESS_LOGIC.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/DOMAIN_BUSINESS_LOGIC.md) | Source-of-truth rules for wallets, manual transfer mapping, budgets with dynamic database-level rollover, saving goals, and authentication (in Vietnamese). |
| **Start a New Feature Workflow** | [`PIPELINE.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/PIPELINE.md) | Standard 10-phase development lifecycle (Requirement through Done) mapping checklists, inputs, outputs, and DoD metrics. |
| **Read or Record Core Decisions** | [`MEMORY.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/MEMORY.md) | Log of historical architecture decisions, framework/library selections, state management choices, and known constraints. Append new decisions here. |
| **Template: Plan a Feature** | [`FEATURE_TEMPLATE.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/FEATURE_TEMPLATE.md) | Copy-paste template for design specifications, database models, services, providers, controllers, and checklists for new features. |
| **Template: Plan a Bug Fix / Task** | [`TASK_TEMPLATE.md`](file:///d:/k%C3%AC%208/Prm_Project/FINORA/.agents/TASK_TEMPLATE.md) | Copy-paste template for defining scoped tasks, files to edit/avoid, and localized verification tests. |

---

## Token Optimization & Usage Rules

1. **Lazy Loading:** Do not load all markdown files at once. Read the global rules in `CLAUDE.md` at the root first, and then open the targeted markdown file from this folder based on your current task.
2. **Referencing:** In your prompts and plans, reference these files (e.g. "Following `STYLE_GUIDE.md`...") to confirm compliance and prevent repeating guidelines.
3. **No Redundancy:** Avoid duplicating guidelines or specifications across these files. If a rule exists in `STYLE_GUIDE.md`, do not replicate it in `CLAUDE.md` or `ARCHITECTURE.md`; link to it instead.
4. **Maintenance:** Keep these documents synchronized with the repository. If you make a permanent architecture decision, append it to `MEMORY.md`.
