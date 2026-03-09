---
description: Implement one planned task in the codebase with focused validation
argument-hint: <epic-slug> <story-number>-<task-number>
allowed-tools: [Read, Glob, Grep, Write, Edit, Bash, Agent, AskUserQuestion, Skill]
---

# Task Implementation

This command is a single step of a longer pipeline:
```text
a-epic -> a-architecture -> a-story(s) -> a-task(s)
                                   ^current
```
Next: user review, then another `/a-task` if needed

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | `./planning/<epic-slug>/story-<story-number>-tasks.md` | Ordered task list produced by `/a-story` |
| **In** | `./planning/<epic-slug>/architecture.md` | Epic-specific architecture and constraints |
| **In** | `./planning/<epic-slug>/story-<story-number>.md` | Detailed story context and story-level UI references when the task list alone is not enough |
| **In/Out** | `./planning/glossary.md` | Shared naming baseline from `/a-global-architecture`; update only with durable confirmed names, code names, sources, or statuses |
| **Conditional In/Out** | `./planning/global-architecture.md` | Read and update only when implementation reveals durable cross-epic structure |
| **Out** | codebase | Code changes, tests, and other implementation artifacts required by the selected task |

## Skills

Invoke these skills when relevant:
- `ecoologic-code` before writing or modifying application code
- `react-best-practices` when touching React components
- `typescript-best-practices` when touching TypeScript or JavaScript
- `ux-laws` when implementing user-facing interaction flows
- `web-design-guidelines` when implementing or adjusting web UI
- `explore` for tightly scoped discovery in multiple code areas
- `conflict-resolution` if merge conflicts are encountered

## Purpose

Implement exactly one planned task, grounded in the approved planning artifacts and the real codebase.

This command should:
- load the selected task and its acceptance criteria
- investigate only the code areas needed to implement that task safely
- make the smallest coherent code change that satisfies the task
- validate the result with focused checks
- promote durable findings back into planning artifacts only when they will help future work

## Rules

- NEVER start coding before loading the selected task, the epic architecture, and the glossary
- NEVER implement a different task than the one requested
- NEVER silently ignore the `Depends on` field
- NEVER broaden scope into unrelated cleanup, opportunistic refactors, or the next task
- NEVER define synonyms; if a glossary term exists, use its canonical name
- NEVER propose speculative abstractions or extractions for future use
- NEVER rewrite planning artifacts without a durable reason
- NEVER create commits or auto-chain into the next task
- Prefer existing code patterns, file placement conventions, and interfaces over inventing new ones
- Add or update tests when the repo already has a relevant testing pattern and the task changes behavior
- Run the smallest meaningful validation that can prove the task works

## Step 1: Resolve required inputs

`$ARGUMENTS` = `<epic-slug> <story-number>-<task-number>`

If either `<epic-slug>` or `<story-number>-<task-number>` is empty or missing, stop and ask the user to provide both values. Do not guess or continue with partial context.

Derive:
- `<story-number>` from the part before the hyphen
- `<task-number>` from the part after the hyphen

Read:
- `./planning/<epic-slug>/story-<story-number>-tasks.md`
- `./planning/<epic-slug>/architecture.md`
- `./planning/glossary.md`

Read `./planning/<epic-slug>/story-<story-number>.md` if any of these are true:
- the task description is too brief to understand the user-facing outcome
- the task acceptance criteria refer to UX or flows not fully described in the task file
- the task changes UI, interaction behavior, or presentation details
- the architecture file references story-local constraints that need clarification

If `story-<story-number>-tasks.md` or `architecture.md` is missing, report the exact path checked and stop.

If `glossary.md` is missing, stop and tell the user to run `/a-global-architecture` first.

Also follow references from every planning artifact read in this step, including `story-<story-number>.md` when it is loaded. Treat each followed reference as required input for this run. If any followed reference cannot be found, accessed, or read, stop and report the exact reference and the file that referenced it.

When `story-<story-number>.md` is loaded and contains a `UI References` section, treat those references as required input for this task. Read and follow them before implementing UI behavior.

Extract the requested task section from `story-<story-number>-tasks.md`:
- task title
- type
- files
- depends on
- description
- acceptance criteria
- notes

Output:
```text
Task: <story-number>-<task-number> <title>
Type: <type>
Files: <list>
Depends on: <none | task ids>
Architecture: loaded
Story context: <loaded | skipped>
UI references: <loaded | not needed>
```

If the task is not found, list the available task ids from the file and stop.

Before editing code, confirm that the relevant planning artifacts were already reviewed and approved by the user. If approval is not evident in the current conversation, ask the user to confirm before proceeding.

If `Depends on` is not `none`, verify that the prerequisite task outcome already exists in the codebase or ask the user before proceeding. Do not assume the dependency is satisfied just because it appears earlier in the file.

## Step 2: Investigate the target code paths

Use the task's `Files` list, the architecture guidance, and the glossary to drive targeted code exploration.

Inspect:
1. the listed files if they exist
2. the nearest collaborating files, types, services, components, or tests
3. current naming, placement, and validation patterns

Use targeted search and explore agents only around the selected task's area. Do not do broad repo exploration.

Each investigation result should report:
- relevant files
- why they matter
- existing patterns to follow
- reusable code or tests
- naming matches or conflicts with the glossary
- risks or gaps that could change the implementation approach

Display the investigation summary before making edits.

## Step 3: Reconcile the plan with the real codebase

Map the task acceptance criteria to concrete implementation changes.

Decide:
1. which listed files will actually change
2. whether supporting tests are required
3. whether any planned file paths should be adjusted to match real repo conventions
4. whether the task can be completed without pulling in another planned task

If the task conflicts with the current codebase or the architecture in a way that materially changes scope, stop and ask the user before editing.

If implementation reveals that the selected task is underspecified but still safely completable, document the interpretation you are using and keep the change minimal.

If implementation would require completing another planned task first, stop and report the dependency rather than folding extra work into this run.

## Step 4: Implement the task

Invoke `ecoologic-code` before making application code changes.

Invoke language- or UI-specific skills when relevant:
- `typescript-best-practices` for TypeScript or JavaScript
- `react-best-practices` for React UI
- `ux-laws` and `web-design-guidelines` for user-facing UI

Implement the task by:
1. modifying only the files required for this task, plus minimal supporting files such as tests or necessary wiring
2. preserving existing working behavior outside the task scope
3. following the codebase's current naming and placement conventions
4. keeping abstractions task-justified, not future-proofed

If the task file lists a path that does not exist:
- create it only if the architecture and local conventions make that the correct target
- otherwise, follow the nearest valid project convention and note the adjustment in the final summary

If part of the task is already implemented:
- reuse the existing implementation
- finish only the missing acceptance criteria
- avoid rewriting working code just to match an imagined ideal

## Step 5: Validate with focused checks

Use `Bash` for validation commands.

Run the smallest meaningful verification first:
1. targeted tests for the changed module, component, endpoint, or workflow
2. targeted lint, format, or type checks when available
3. broader package- or app-level checks only when focused checks are unavailable or clearly insufficient

If the task changes behavior and the repo has a relevant test pattern, add or update tests before considering the task done.

If a validation failure is inside the selected task's scope:
- fix it
- rerun the relevant validation
- repeat until the task passes or a real blocker appears

If a validation failure is clearly unrelated or pre-existing:
- stop after confirming it is outside this task's scope
- report the exact command and failure
- explain why it was not fixed as part of this task

If no automated validation exists, say so explicitly and perform a manual acceptance-criteria review against the changed code.

## Step 6: Apply durable planning updates

Update planning artifacts only when implementation reveals durable knowledge worth preserving for later work.

Allowed updates:
- update `./planning/<epic-slug>/architecture.md` when implementation reveals epic-specific technical truth that later tasks should inherit
- update `./planning/glossary.md` when a durable domain term, code name, source, or status is confirmed
- update `./planning/global-architecture.md` only when implementation reveals durable cross-epic structure, boundaries, contracts, or communication paths

Do not:
- push temporary debugging notes into planning artifacts
- silently rename an existing glossary term
- rewrite the task list just because the implementation was harder than expected
- backfill speculative future work into architecture documents

Summarize every planning-artifact update before finishing.

## Step 7: Present the result to the user

Summarize:
1. files changed
2. acceptance criteria covered
3. validation run and result
4. planning updates applied
5. remaining blockers, follow-ups, or risks
6. whether the next task is now unblocked

Ask the user to review the implementation before running another `/a-task`.

## Success Criteria

- [ ] the selected task was located from `story-<story-number>-tasks.md`
- [ ] all required inputs and followed references were validated before implementation continued
- [ ] only the selected task's scope was implemented
- [ ] changed files follow existing local patterns and canonical glossary naming
- [ ] focused validation ran, or the lack of automation was explained explicitly
- [ ] relevant tests were added or updated when a matching test pattern exists
- [ ] relevant UI references were loaded before implementing UI behavior
- [ ] any durable glossary or architecture updates were applied deliberately
- [ ] the user reviewed the result before the pipeline advanced

## Error Handling

- **Empty arguments** — ask the user to provide both `<epic-slug>` and `<story-number>-<task-number>`
- **Invalid task id format** — explain the expected format `<story-number>-<task-number>` and stop
- **Missing `story-<story-number>-tasks.md`** — report the exact path checked and tell the user to run `/a-story <epic-slug> <story-number>`
- **Missing `architecture.md`** — report the exact path checked and tell the user to run `/a-architecture <epic-slug>`
- **Missing `glossary.md`** — tell the user to run `/a-global-architecture` first
- **Missing or unreadable followed reference** — report the exact reference and originating file and stop instead of skipping it
- **Task not found** — list available task ids from the tasks file and ask the user to pick one
- **Unsatisfied dependency** — report the dependency and stop before editing code
- **Task/architecture/codebase conflict** — surface the conflict clearly and ask the user before widening scope
- **Validation blocked by unrelated existing failure** — report the exact command, the failure, and why it is out of scope
- **Merge conflicts encountered** — invoke `conflict-resolution`, resolve carefully, verify the result, and then continue only if task scope is still intact
