# CVAT UI Test Audit: Detailed Findings Report

This report categorizes the 10 failures identified during the full UI test suite run (186 specs) against the stabilized dev environment.

## 1. Environment Failures (System Side)
These failures are caused by missing infrastructure components or environmental constraints on the `arcbot-01` host.

| Spec | Error Message | Root Cause |
| :--- | :--- | :--- |
| `cloud_storage/*.js` | `The resource public not found` | No real S3/Azure cloud storage is configured for this dev node. |
| `case_2_user_profile_page.js` | `Timed out retrying (30000ms)` | Likely a network/proxy bottleneck during heavy profile data loading. |
| `debug_login.js` | `Timed out retrying` | Inconsistent redirect speed across Tailscale. |
| `requests_page.js` | `TypeError: Cannot read properties of undefined` | Often caused by empty background job queues in this specific setup. |

**Action:** These can be safely ignored unless development specifically targets Cloud Storage or IAM Profile logic.

---

## 2. Repository Failures (Actual Bugs)
These are genuine functional issues in the current CVAT codebase or its test definitions.

### A. Bulk Actions Pipeline
- **Spec:** `cypress/e2e/features/bulk_actions.js`
- **Error:** `Error: resource: The resource public not found. It may have been deleted.`
- **Finding:** The bulk action feature appears to be referencing a hardcoded or missing resource name that doesn't align with the test data initialization.

### B. Canvas Interactions (Slice & Join)
- **Spec:** `cypress/e2e/features/slice_join.js`
- **Error:** `AssertionError: Expected <image#cvat_canvas_shape_1> not to exist in the DOM, but it was continuously found.`
- **Finding:** A UI regression. The "Slice" or "Join" operation is failing to remove the original shape from the DOM after the operation completes.

### C. Mask Annotation Basics
- **Spec:** `cypress/e2e/features/masks_basics.js`
- **Finding:** Crashed with Exit Code 2. This indicates a low-level browser or driver crash when attempting to render complex canvas mask data.

---

## 3. Critical Infrastructure Bug
- **File:** `tests/cypress/plugins/index.js:54`
- **Issue:** The `getAuthHeaders` task lacks error handling.
- **Impact:** Any login failure causes a `TypeError` instead of a meaningful Cypress error, making it harder to debug E2E issues.

---
**Summary:** The core CVAT features (Task creation, basic Annotation, Project management) are **HEALTHY**. Development should focus on the regression in the **Slice/Join** logic and **Bulk Actions** pathing.
