# **Operational Rule: Model Cascading and Routing Guidelines**

To maximize processing speed, minimize latency, prevent context distraction, and control token consumption costs, all agent-driven tasks must be dynamically routed according to this **Model Cascading** rule. This framework divides processing between lightweight, high-speed models and heavyweight, multi-step reasoning models.

---

## **1. Core Allocation Philosophy**

*   **Gemini Flash (Cost-Efficient / High-Throughput)**: Recommended for low-complexity, deterministic text processing, file parsing, formatting, log filtering, syntactic audits, and single-file spec reviews.
*   **Gemini Pro (Deep Reasoning / Complex Context)**: Reserved for high-complexity architectural design, multi-file code synthesis, Test-Driven Development (TDD) iteration, debugging of recursive errors, and deep system boundary negotiations.

---

## **2. Task Routing and Model Assignment Matrix**

All operations executed by workflows must abide by the following classification matrix:

| Workflow Step | Operation | Target Model | Routing Rationale |
| :--- | :--- | :--- | :--- |
| **PO Scoping** | `/interview-prd` | **Gemini Pro** | Requires deep interactive reasoning, comparative synthesis of architectural choices, and generation of a 360° decision matrix. |
| **Audit Gateway** | `/audit-prd` | **Gemini Flash** | Structural checklist verification of the PRD against the 6 pillars. Does not require advanced reasoning, but strict compliance matching. |
| **Arch Verification**| `/arch-gate` | **Gemini Pro** | Multi-dimensional impact analysis. Formulates the immutable base in `docs/architecture.md`. |
| **Backlog Decomp** | `/prd2backlog` | **Gemini Flash** | Standard breakdown of structured PRD sections into flat specs files. |
| **Specification** | `/specify` | **Gemini Pro** | Structural drafting of boundaries, type contracts, inputs/outputs, and invariants. High-fidelity architectural reasoning is required. |
| **Spec Audit** | `/review-spec` | **Gemini Flash** | Verification of specifications against `docs/architecture.md` schemas. Straightforward compliance gate. |
| **TDD Code Cycle** | `/tdd-build` | **Gemini Pro** | Complex iterative *Red-Green-Refactor* cycles, dependency troubleshooting, and code structure repairs. |
| **E2E Integration** | `/e2e-test` | **Gemini Pro** | Playwright browser flow orchestrator, error state parsing, DOM structural analysis. |
| **Merge & Release** | `/ship` | **Gemini Flash** | Formatting of rule traceability metadata, generating diff logs, checking commit message compliance, and packaging. |

---

## **3. Token Optimization & Context Clean-up Rules**

Regardless of the model routed, agents must follow strict context control rules:

### **3.1 Stateless Context Resets**
Agents must avoid carrying full conversation histories into subsequent steps. 
*   **Action**: Before triggering `/tdd-build` or `/e2e-test`, the environment context must be purged.
*   **Supplied Variables**: Only pass the following three components:
    1.  The immutable `docs/architecture.md`.
    2.  The current task spec `docs/specs/issue-X.md`.
    3.  The exact target source file and corresponding test file.

### **3.2 Log Trimming and Filtering**
To prevent context window bloat and model distraction, agents are prohibited from consuming unfiltered log files.
*   **Liner Output**: Logs containing external packaging details, environment setups, and third-party warnings must be stripped locally by standard shell scripts.
*   **Inject Structure**: When injecting errors, only supply:
    *   The failing test assertion message.
    *   The offending line number.
    *   The filename and up to 10 surrounding lines of source code.

### **3.3 Targeted Diff Patching**
*   **Standard**: Agents must generate targeted Unified Diff output formats. Regenerating entire files of 100+ lines for minor fixes is considered an anti-pattern and will be blocked by pre-tool hooks.
