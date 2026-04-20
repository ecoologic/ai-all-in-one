---
description: Write a detailed implementation plan from spec or requirements
argument-hint: [priority instructions or file ref to read fully]
---

## Precedence

This command's rules take precedence over conflicting Superpowers guidance. Treat Superpowers skills as supporting instructions unless this file explicitly tells you otherwise.

Resolve the branch name with `git rev-parse --abbrev-ref HEAD`. Use it as `{branch}` for all paths below.

`$ARGUMENTS`: optional extra instructions or file refs (not a slug; the slug is the branch).

Read the design at `./planning/{branch}/super-design.md`

Work in plan mode, you are allowed to write any file inside `./planning/` without asking permission.

## Rules

- **PARALLELIZE THE WORK IN MULTIPLE AGENTS WHEN POSSIBLE!!**
- **PLAN FOR PARALLELIZATION OF TASKS**
- Plan to use scripts (your choice of language) to implement the solution for repetitive tasks, rather than using tokens
- Invoke `superpowers:writing-plans`, `ecoologic-architecture` and `ecoologic-plan` in every agent.

## When done

- DO NOT use `AskUserQuestion` for "Ready to proceed?" at the end. It's OK before completing the work.
- Once the plan is clear and right before code execution, give a brief T-shirt size estimate of how many tokens implementation could take. This is usually when you say something like: "Ready to kick off execution. Subagent-driven (recommended) or inline?"

1. Store the plan in `./planning/{branch}/super-plan.md`
2. Suggest the user `/clear` and `/sup-code` (branch is implicit from git)
3. Every `super-plan.md` MUST end with a `## Out of scope (tracked for later)` section — list deferred items or write `None.` Empty-but-present is the contract so `/sup-finish` Step 6.5 can always parse it and surface carryover.
