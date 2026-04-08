---
name: ecoologic-debug
description: "Use when debugging bugs, test failures, errors, or unexpected runtime behavior before attempting a fix."
---

## Principles

- ALWAYS report findings before moving on to implementation — show what you found, what you think is wrong, and why, before touching code
- NEVER start implementing a fix before confirming the diagnosis with the user — wrong assumptions lead to wrong fixes
- ALWAYS plan a rollback to avoid leaving the DB or runtime in a broken state — if the fix fails, the system must still work
- ALWAYS update the tests (red->green) once you found the issue to cover the fix
