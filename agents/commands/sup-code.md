---
description: Execute a written implementation plan
argument-hint: [priority instructions or file ref to read fully]
---

Never reference development tools, development documents (design, plan), or Superpowers materials in the produced code, comments or commit messages.

**Precedence**

This command's rules take precedence over conflicting Superpowers guidance. Treat Superpowers skills as supporting instructions unless this file explicitly tells you otherwise.

Resolve the branch name with `git rev-parse --abbrev-ref HEAD`. Use it as `{branch}` for all paths below.

`$ARGUMENTS`: optional extra instructions or file refs (not a slug; the slug is the branch).

Read the plan at `./planning/{branch}/super-plan.md`

**PARALLELIZE TASK EXECUTION IN MULTIPLE NON-CONFLICTING AGENTS!!**
**DO NOT** write any test! We'll do that at in another process, with different skills.

Invoke `superpowers:executing-plans`, `ecoologic-architecture` and `ecoologic-code` in every agent.

If, at any point, you find bugs, invoke `ecoologic-debug` and `superpowers:systematic-debugging`.

## When done

* DO NOT use user interaction tools like questions. It's OK before completing the work, but don't ask: "Ready to proceed?"
* Suggest the user run `/clear` and `/sup-finish` to verify the work
