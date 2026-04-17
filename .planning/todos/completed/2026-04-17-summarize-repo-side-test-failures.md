---
created: 2026-04-17T04:22:15.000Z
title: Summarize repo-side test failures
area: testing
files:
  - tests/sequential_run.log
  - README_TESTING.md
---

## Problem

After running the full suite of 186 UI tests, the log contains a mix of "false negative" failures (due to system-level timeouts, Tailscale lag, or destructive database states) and genuine "repo-side" bugs. To begin effective development, we need a clear, filtered summary that isolates only the actual repository-level issues.

## Solution

Once the `run_ui_tests_sequential.sh` script completes its run:
1.  Parse the `sequential_run.log` to identify all `RESULT: FAILED` entries.
2.  Analyze each failure to determine if it was caused by a timeout (>30s) or a known system-level issue (like the TTY warning).
3.  Generate a categorized report in a new file (e.g., `AUDIT_RESULTS.md`) that lists only the specs with genuine logic or data bugs, including the error message and a reference to the recorded video.
