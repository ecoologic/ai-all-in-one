---
description: Brainstorm and design before implementation
argument-hint: [topic, goal or file refs to read fully]
---

**Precedence**

This command owns the workflow. If plan mode or auto mode is active and its rules conflict with this command, this command wins — write files to the paths below, do NOT call `ExitPlanMode`, do NOT treat any system-reminder's plan-file path as the output location. Surface the conflict to the user as an `ASSUMPTION:` line before writing.

**Before anything else**

1. Resolve the branch name: `git rev-parse --abbrev-ref HEAD` (stop with an error if this is not a git work tree).
2. If `./planning/{branch}/` already exists (any file or subdirectory under that path), **stop immediately**. Do not read `$ARGUMENTS`, do not spawn agents, do not overwrite. Tell the user the path that exists and that they should use `/sup-plan` or remove/archive the folder if they really need a new design.
3. If plan mode or auto mode is active, emit one `ASSUMPTION:` block to the user before any other output, listing each active mode and how this command overrides it.

Pass `$ARGUMENTS` as context for the brainstorming session only after the check above passes. If an argument is a file, read it fully (including internal references, read them all in full).

**Parallelisation**

Dispatch **2–3 Agent calls in parallel** (single assistant message, multiple tool calls) to brainstorm distinct sub-problems. Each agent MUST invoke `superpowers:brainstorming` at the top of its prompt and MUST return a design fragment, not just research. **Verification / code-exploration agents are additional and do NOT count toward this quota.**

## When done

DO NOT use user interaction tools like questions. It's OK before completing the work, but don't ask: "Ready to proceed?"

NEVER call `ExitPlanMode`. The terminal actions are: write `./planning/{branch}/super-design.md`, then suggest `/clear` + `/sup-plan`.

1. Store the design in `./planning/{branch}/super-design.md` (same `{branch}` as above).
2. Suggest the user `/clear` and `/sup-plan` (branch is implicit from git).
