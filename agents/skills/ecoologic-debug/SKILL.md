---
name: ecoologic-debug
description: "MUST USE when debugging bugs, test failures, or unexpected behavior. TRIGGER when: investigating errors, fixing bugs, diagnosing test failures, or troubleshooting runtime issues."
---

## Principles

- ALWAYS report findings before moving on to implementation — show what you found, what you think is wrong, and why, before touching code
- NEVER start implementing a fix before confirming the diagnosis with the user — wrong assumptions lead to wrong fixes
- ALWAYS plan a rollback to avoid leaving the DB or runtime in a broken state — if the fix fails, the system must still work
