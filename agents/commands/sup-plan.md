---
description: Write a detailed implementation plan from spec or requirements
argument-hint: [priority instructions or file ref to read fully]
---

Resolve the branch name with `git rev-parse --abbrev-ref HEAD`. Use it as `{branch}` for all paths below.

`$ARGUMENTS`: optional extra instructions or file refs (not a slug; the slug is the branch).

Read the design at `./planning/{branch}/super-design.md`

**PARALLELIZE THE WORK IN MULTIPLE AGENTS WHEN POSSIBLE!!**
**PLAN FOR PARALLELIZATION OF TASKS**

Invoke `superpowers:writing-plans`, `ecoologic-architecture` and `ecoologic-plan` in every agent.

## When done

DO NOT use user interaction tools like questions. It's OK before completing the work, but don't ask: "Ready to proceed?"

1. Store the plan in `./planning/{branch}/super-plan.md`
2. Suggest the user `/clear` and `/sup-code` (branch is implicit from git)
3. Every `super-plan.md` MUST end with a `## Out of scope (tracked for later)` section — list deferred items or write `None.` Empty-but-present is the contract so `/sup-finish` Step 6.5 can always parse it and surface carryover.
