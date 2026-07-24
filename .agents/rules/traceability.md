# **Operational Rule: End-to-End Audit Traceability**

To guarantee 100% auditability and verify that every modification directly supports a business requirement without introducing regressions or unapproved features, this project enforces strict **End-to-End Traceability**. Every artifact, issue, code block, unit test, and git commit must contain direct references to high-level PRD Rules and operational issue IDs.

---

## **1. The Traceability Audit Chain**

Traceability must form an unbroken, bi-directional verification loop:

```
  [PRD Rule ID [Rn]]
         ↕ (PRD Decomposition)
  [Issue ID (#xxx)]
         ↕ (Detailed Specification)
  [Technical Spec (specs/issue-xxx.md)]
         ↕ (Type-Driven Contract)
  [Source Code Annotations (src/core/ & src/shell/)]
         ↕ (TDD Verification)
  [Unit/E2E Tests (test_rule_Rn)]
         ↕ (Shipping Gate)
  [Commit Message (type(scope): summary [Rn] (#xxx))]
```

---

## **2. Requirements for Traceability Identifiers**

### **2.1 PRD Rule Identifiers (`[Rn]`)**
*   All operational criteria, business rules, edge-case handlings, database schemas, and security compliance matrices listed in `docs/PRD.md` must be prefaced by a unique rule identifier in brackets.
*   **Format**: `[R<number>]` or `[Rn]` where `<number>` is an incremental integer.
    *   *Examples*: `[R1]`, `[R10]`, `[R105]`.
*   **Sub-rules**: Nested clauses can be represented as sub-rules.
    *   *Examples*: `[R1.1]`, `[R1.2]`, `[R10.3]`.

### **2.2 Issue and Backlog IDs (`#xxx`)**
*   Every task specification generated under `docs/specs/` must be mapped to a specific GitHub issue number.
*   **GitHub Synchronization**: Issue creation is managed automatically by `/prd2backlog` using the `gh` CLI. The resulting GitHub issue number (e.g., `#123`) is dynamically written back to the local `docs/specs/issue-*.md` file.
*   **Format**: `#<number>` (e.g., `#12`, `#345`).


---

## **3. Code and Test Annotation Rules**

### **3.1 Source Code Annotations**
All new business functions and class structures inside the Functional Core (`src/core/`) must be annotated with a docstring or comment linking back to its governing PRD rule.
*   **TypeScript Example**:
    ```typescript
    /**
     * Calculates user discount based on loyalty tier.
     * @see docs/PRD.md [R4.2] - Loyalty Program Rules
     * @see docs/specs/issue-12.md
     */
    export function calculateLoyaltyDiscount(tier: string, basePrice: number): number { ... }
    ```
*   **Python Example**:
    ```python
    def calculate_loyalty_discount(tier: str, base_price: float) -> float:
        """
        Calculates user discount based on loyalty tier.
        Conforms to PRD [R4.2] and spec issue-12.
        """
        ...
    ```

### **3.2 Test Suite Traceability**
Each unit test and integration test case must clearly associate its assert boundaries with the PRD rule ID it validates.
*   **Test Case Naming**: Test functions must include the target rule in their names.
    *   *TypeScript*: `it("should calculate correct gold discount to satisfy [R4.2]", () => { ... })`
    *   *Python*: `def test_loyalty_discount_gold_conforms_to_R4_2():`

---

## **4. Commit Message Standard**

All automated commits and manual developer contributions must strictly follow this custom Conventional Commits pattern. The pre-commit hook will reject any commit that does not match this structure.

### **4.1 Syntax Pattern**
```
<type>(<scope>): <summary> [<PRD_ID>] (<Issue_ID>)
```

*   **Allowed `<type>` Values**:
    *   `feat`: A new user-facing or core-logic feature.
    *   `fix`: A bug fix or logical correction.
    *   `docs`: Changes to documentation files only.
    *   `style`: Code formatting changes (whitespace, semi-colons, no logical change).
    *   `refactor`: Restructuring code without changing its external behavior or passing tests.
    *   `test`: Adding missing tests or correcting existing tests.
    *   `chore`: Updating build scripts, dependencies, or pipeline configurations.
*   **Allowed `<scope>` Values**: Must represent the directory or component modified (e.g., `core`, `shell`, `deps`, `pipeline`, `infra`).
*   **`<PRD_ID>` Requirement**: Must contain the exact PRD ID in brackets (e.g., `[R4.2]`). If multiple rules are addressed, comma-separate them (e.g., `[R1.1, R1.2]`).
*   **`<Issue_ID>` Requirement**: Must contain the exact issue number prefixed by `#` in parentheses (e.g., `(#45)`).

### **4.2 Compliance Examples**

*   **Valid Feature Commit**:
    ```
    feat(core): implement loyalty discount model [R4.2] (#12)
    ```
*   **Valid Bug Fix Commit**:
    ```
    fix(shell): correct postgres transaction pooling crash [R10.5] (#34)
    ```
*   **Invalid Commits (Rejected by Hook)**:
    ```
    add loyalty discount model (Missing type, scope, PRD ID, and Issue ID)
    feat(core): added validation rules [R1] (Missing issue ID)
    fix: resolved user registration bug (#45) (Missing scope and PRD ID)
    ```

### **4.3 Verification Regex**
The pre-commit validation engine uses the following regular expression to parse commit compliance:
```regex
^(feat|fix|docs|style|refactor|test|chore)\([a-zA-Z0-9_\-]+\):\s.+\[R[0-9]+(\.[0-9]+)*(\s*,\s*R[0-9]+(\.[0-9]+)*)*\]\s+\(#[0-9]+\)$
```
