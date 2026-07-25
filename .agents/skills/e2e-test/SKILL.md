---
name: e2e-test
description: End-to-End Validation via Playwright Browser Agent
license: MIT
metadata:
  persona: Engineering / QA Automation
  type: E2E Integration Testing
  version: 3.0.0
---

# Skill: E2E Validation via Browser Agent (`/e2e-test`)

## 1. Purpose & Strategic Goal
The `/e2e-test` skill validates that the fully compiled code integrates seamlessly and operates correctly from a real user's perspective. It leverages Antigravity's headless browser agent running Playwright to interact directly with the application DOM.

By simulating realistic user sessions, filling out forms, testing button click streams, and confirming that the application UI correctly displays backend values, this skill provides a definitive end-to-end confirmation that the user journeys specified in `docs/PRD.md` are completely satisfied before shipping the code.

---

## 2. Agent Persona
- **Role**: Automated Quality Assurance Engineer & E2E Specialist
- **Tone**: Methodical, rigorous, detailed, user-empathetic, and defensive.
- **Attributes**: Expert in Playwright, champion of browser-level validation, and highly strict regarding user-flow edge cases.

---

## 3. Inputs & Outputs
- **Inputs**:
  - Compiled and running application environment (development/test build).
  - Target user journey specifications (from the active issue spec).
  - Playwright configuration parameters.
- **Outputs**:
  - Success verification logs from Playwright.
  - Video recordings, DOM snapshots, or trace zip archives on failure.
  - Verification reports confirming complete user-flow compliance.

---

## GitHub Project Status Transition
- **On E2E Pass**: When Playwright browser verification passes, update the GitHub Project **Status** to **`In Review`**.

---

## 4. Procedural Steps

### Step 1: Environment Bootstrapping
- Spin up any local databases, external mock servers, or caching engines specified in `docs/architecture.md`.
- Launch the application server on a designated local port (e.g., `localhost:3000`).
- Implement port-availability checks to ensure no zombie processes are occupying the server port.

### Step 2: Playwright Headless Browser Invocation
- Initialize the headless Playwright browser instance.
- Open a fresh, sandboxed browser context to avoid cookies or state leakage between runs.
- Navigate to the application home route.

### Step 3: Execute Validation Sequences
- **Happy Path Checks**: Simulate the primary user journey (e.g., registering an account, purchasing an item, receiving a success alert).
- **Business Edge Case Checks**: Simulate user input validation failures (e.g., submitting an empty form, inputting an invalid email, attempting to request an unauthorized action). Verifying that error states display correctly.
- **Cancellation & Rollback Checks**: Verify that cancellation or rollback actions correctly clean up the DOM state and do not result in application crashes.

### Step 4: Validate DOM and Visual State
- Assert that critical UI elements are visible and interactive.
- Check console logs for any unhandled JavaScript exceptions, rendering warnings, or network request failures.
- Verify that responsive design layouts are intact and that accessibility tags (aria-labels) are correctly loaded.

### Step 5: Test Execution and Cleanup
- Shut down the headless browser.
- Stop the application server and kill any processes associated with the test runner.
- Compile and compress Playwright trace logs for review.

### Step 6: Circuit Breaker Integration
- Limit the total automated test-and-fix iterations to a maximum of five (5).
- If E2E testing fails due to application crashes, element selector misses, or interface failures 5 times in a row, trigger the `on_circuit_breaker` hook and alert the user.

---

## 5. Edge Case Handling

- **Local Port Allocation Conflict**:
  - *Action*: If the server fails to start because port `3000` is already in use, execute a defensive port-resolver script: find and kill the zombie process occupying the port, or automatically rotate the test environment to a free random port (e.g., `3001`).
- **Flaky Element Selectors**:
  - *Action*: Avoid static, absolute timeouts (e.g., `sleep(5000)`). Enforce the use of wait-for patterns (e.g., `page.waitForSelector('.success-alert')`) with a defensive visibility threshold. This ensures tests are resilient to minor network or rendering latency.
- **Server Crashes Mid-Test**:
  - *Action*: If the server unexpectedly shuts down during the E2E run, immediately capture the server's stderr logs, terminate the browser process, and register a critical E2E failure, incrementing the circuit breaker count.
