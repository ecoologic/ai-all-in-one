---
description: Execute a written implementation plan
argument-hint: [priority instructions or file ref to read fully]
---

## Output hygiene

Invoke skills (`superpowers:*`, `ecoologic-*`) freely as part of your workflow — that's how the work gets done. But **never mention** development tools, design/plan documents, or Superpowers materials in **artifacts the user ships**: produced code, comments, commit messages, or PR descriptions. Internal invocation = yes; visible attribution in shipped output = no.

## Precedence

Order: **`ecoologic-*` > this command > `superpowers:*`**. `ecoologic-*` skills override this file; this file overrides Superpowers guidance. Treat Superpowers skills as supporting instructions unless this file explicitly tells you otherwise.

Resolve the branch name with `git rev-parse --abbrev-ref HEAD`. Use it as `{branch}` for all paths below.

`$ARGUMENTS`: optional extra instructions or file refs (not a slug; the slug is the branch).

Read the plan at `./planning/{branch}/super-plan.md`

## Parallelisation

Invoke `superpowers:dispatching-parallel-agents`. Group plan tasks into non-conflicting domains (different files, different subsystems, no shared state) and dispatch one agent per domain in a single assistant message. Tasks that touch the same files or depend on each other run sequentially.

**DO NOT** write any test! We'll do that at in another process, with different skills.

Invoke `superpowers:executing-plans`, `ecoologic-architecture` and `ecoologic-code` in every agent.

If, at any point, you find bugs, invoke `ecoologic-debug` and `superpowers:systematic-debugging`.

## When done

* DO NOT use user interaction tools like questions. It's OK before completing the work, but don't ask: "Ready to proceed?"
* Suggest the user run `/clear` and `/sup-finish` to verify the work
