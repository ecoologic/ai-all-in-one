---
description: Implement one planned acceptance criterion in the codebase with focused validation
argument-hint: [epic-slug] <story-number>-<criterion-number>
allowed-tools: [Read, Glob, Grep, Write, Edit, Bash, Agent, AskUserQuestion, Skill]
---

# Criterion Implementation

This command is a single step of a longer pipeline:
```text
a-epic -> a-architecture -> a-story(s) -> a-criterion(s)
                                        ^current
```
Next: user review, then another `/a-criterion` if requested

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In/Out** | `./planning/<epic-slug>/story-<story-number>.md` | Story context, story-level completion status, numbered acceptance criteria, and implementation-plan tasks produced by `/a-story`; `/a-criterion` updates only the selected criterion's completion state in this file |
| **In** | `./planning/<epic-slug>/architecture.plan.md` | Epic-specific architecture and constraints |
| **In/Out** | `./planning/glossary.md` | Shared naming baseline from `/a-global-architecture`; update only with durable confirmed names, code names, sources, or statuses |
| **Conditional In/Out** | `./planning/global-architecture.plan.md` | Read and update only when implementation reveals durable cross-epic structure |
| **Out** | codebase | Code changes, tests, and other implementation artifacts required by the selected acceptance criterion |

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

Implement exactly one planned acceptance criterion, grounded in the approved planning artifacts and the real codebase.

This command should:
- load the selected acceptance criterion and its implementation-plan tasks
- investigate only the code areas needed to implement that criterion safely
- make the smallest coherent code change that satisfies the criterion
- validate the result with focused checks
- write completion state back to the matching `story-<story-number>.md` file once the selected criterion is done
- stop after the selected criterion unless the user explicitly asks to continue
- promote durable findings back into planning artifacts only when they will help future work

## Rules

- NEVER start coding before loading the selected criterion, the epic architecture, and the glossary
- NEVER implement a different acceptance criterion than the one requested
- NEVER confuse the acceptance-criterion selector with the implementation tasks listed under it
- NEVER broaden scope into unrelated cleanup, opportunistic refactors, or the next acceptance criterion
- NEVER define synonyms; if a glossary term exists, use its canonical name
- NEVER propose speculative abstractions or extractions for future use
- NEVER rewrite planning artifacts without a durable reason
- NEVER update any story file except `./planning/<epic-slug>/story-<story-number>.md`
- NEVER create commits or auto-chain into the next criterion
- Prefer existing code patterns, file placement conventions, and interfaces over inventing new ones
- Internal implementation tasks are execution guidance inside the selected criterion, not separate command entrypoints
- Implementation tasks may be story-coherent rather than artificially isolated; if the criterion needs a full table, all story-relevant fields for that slice belong in scope
- Add or update tests when the repo already has a relevant testing pattern and the criterion changes behavior
- Run the smallest meaningful validation that can prove the criterion works

## Step 1: Resolve required inputs

`$ARGUMENTS` = `[epic-slug] <story-number>-<criterion-number>`

If `<story-number>-<criterion-number>` is empty or missing, stop and ask the user to provide it. Do not guess or continue with partial context.

Resolve `<epic-slug>` in this order:
1. explicit argument
2. `./planning/current.json` field `epic-slug`

If the explicit argument is empty or missing, read `./planning/current.json` and use its `epic-slug` value when present.

If neither source provides `<epic-slug>`, stop and ask the user to provide it. Do not guess or continue with partial context.

Derive:
- `<story-number>` from the part before the hyphen
- `<criterion-number>` from the part after the hyphen

Read:
- `./planning/<epic-slug>/story-<story-number>.md`
- `./planning/<epic-slug>/architecture.plan.md`
- `./planning/glossary.md`

Treat `story-<story-number>.md` as the single planning contract for this command.

If `story-<story-number>.md` or `architecture.plan.md` is missing, report the exact path checked and stop.

If `glossary.md` is missing, stop and tell the user to run `/a-global-architecture` first.

If `./planning/current.json` exists but is unreadable, malformed, or missing `epic-slug` when needed for fallback, report that exact problem and stop.

Also follow references from every planning artifact read in this step. Treat each followed reference as required input for this run. If any followed reference cannot be found, accessed, or read, stop and report the exact reference and the file that referenced it.

When `story-<story-number>.md` contains a `UI References` section, treat those references as required input for this criterion. Read and follow them before implementing UI behavior.

Extract from `story-<story-number>.md`:
- the `## Status` section and current story completion marker
- the numbered acceptance criterion ` <criterion-number>. [ ] ...`
- the matching `### Acceptance Criterion <criterion-number>` section from `## Implementation Plan`
- the criterion outcome
- files likely to change
- dependencies
- implementation tasks nested under that criterion
- notes

Output:
```text
Criterion: <story-number>-<criterion-number> <title>
Files: <list>
Depends on: <none | criterion ids | story ids>
Architecture: loaded
Story context: loaded
UI references: <loaded | not needed>
```

If the acceptance criterion is not found, list the available acceptance-criterion numbers from the story file and stop.

If the matching implementation-plan section is missing, report that `story-<story-number>.md` is malformed for `/a-criterion` and stop instead of reconstructing the plan from prose.

Before editing code, confirm that the relevant planning artifacts were already reviewed and approved by the user. If approval is not evident in the current conversation, ask the user to confirm before proceeding.

If `Dependencies` is not `none`, verify that the prerequisite outcome already exists in the codebase or ask the user before proceeding. Do not assume the dependency is satisfied just because it appears earlier in the story file.

## Step 2: Investigate the target code paths

Use the selected criterion's files, implementation tasks, architecture guidance, and glossary to drive targeted code exploration.

Inspect:
1. the listed files if they exist
2. the nearest collaborating files, types, services, components, or tests
3. current naming, placement, and validation patterns

Use targeted search and explore agents only around the selected criterion's area. Do not do broad repo exploration.

Each investigation result should report:
- relevant files
- why they matter
- existing patterns to follow
- reusable code or tests
- naming matches or conflicts with the glossary
- risks or gaps that could change the implementation approach

Display the investigation summary before making edits.

## Step 3: Reconcile the plan with the real codebase

Map the selected acceptance criterion and its implementation tasks to concrete implementation changes.

Decide:
1. which listed files will actually change
2. whether supporting tests are required
3. whether any planned file paths should be adjusted to match real repo conventions
4. whether the criterion can be completed without pulling in another acceptance criterion

If the criterion conflicts with the current codebase or the architecture in a way that materially changes scope, stop and ask the user before editing.

If implementation reveals that the selected criterion is underspecified but still safely completable, document the interpretation you are using and keep the change minimal.

If implementation would require completing another acceptance criterion first, stop and report the dependency rather than folding extra work into this run.

## Step 4: Implement the criterion

Invoke `ecoologic-code` before making application code changes.

Invoke language- or UI-specific skills when relevant:
- `typescript-best-practices` for TypeScript or JavaScript
- `react-best-practices` for React UI
- `ux-laws` and `web-design-guidelines` for user-facing UI

Implement the selected criterion by:
1. modifying only the files required for this criterion, plus minimal supporting files such as tests or necessary wiring
2. preserving existing working behavior outside the selected criterion's scope
3. following the codebase's current naming and placement conventions
4. keeping abstractions criterion-justified, not future-proofed
5. using the implementation tasks as work organization, not as separate stopping points

If the story file lists a path that does not exist:
- create it only if the architecture and local conventions make that the correct target
- otherwise, follow the nearest valid project convention and note the adjustment in the final summary

If part of the selected criterion is already implemented:
- reuse the existing implementation
- finish only the missing acceptance-criterion coverage
- avoid rewriting working code just to match an imagined ideal

## Step 5: Validate with focused checks

Use `Bash` for validation commands.

Run the smallest meaningful verification first:
1. targeted tests for the changed module, component, endpoint, or workflow
2. targeted lint, format, or type checks when available
3. broader package- or app-level checks only when focused checks are unavailable or clearly insufficient

If the criterion changes behavior and the repo has a relevant test pattern, add or update tests before considering the criterion done.

If a validation failure is inside the selected criterion's scope:
- fix it
- rerun the relevant validation
- repeat until the criterion passes or a real blocker appears

If a validation failure is clearly unrelated or pre-existing:
- stop after confirming it is outside this criterion's scope
- report the exact command and failure
- explain why it was not fixed as part of this criterion

If no automated validation exists, say so explicitly and perform a manual acceptance-criteria review against the changed code.

## Step 6: Update story progress

After focused validation passes, update only `./planning/<epic-slug>/story-<story-number>.md`.

Apply these completion updates:
1. in `## Acceptance Criteria`, change only the selected ` <criterion-number>. [ ] ...` entry to checked
2. in `## Implementation Plan`, check only the completed task items under `### Acceptance Criterion <criterion-number>`
3. do not check tasks under any other acceptance criterion

Story-level completion rule:
1. use the `## Acceptance Criteria` checklist as the source of truth for overall story completion
2. if every acceptance criterion in `story-<story-number>.md` is checked after this run, set `## Status` to `- [x] Story complete`
3. otherwise, ensure `## Status` remains `- [ ] Story complete`

If `## Status` is missing, add this canonical section near the top of `story-<story-number>.md` before applying the final story-level state:

```md
## Status
- [ ] Story complete
```

Do not mark the selected criterion or its tasks complete if validation is still failing or the implementation is only partial.

Summarize the exact progress updates before finishing.

## Step 7: Apply durable planning updates

Update planning artifacts only when implementation reveals durable knowledge worth preserving for later work.

Allowed updates:
- update `./planning/<epic-slug>/architecture.plan.md` when implementation reveals epic-specific technical truth that later criteria should inherit
- update `./planning/glossary.md` when a durable domain term, code name, source, or status is confirmed
- update `./planning/global-architecture.plan.md` only when implementation reveals durable cross-epic structure, boundaries, contracts, or communication paths

Do not:
- push temporary debugging notes into planning artifacts
- silently rename an existing glossary term
- rewrite the story's implementation-plan tasks just because the implementation was harder than expected
- backfill speculative future work into architecture documents

Summarize every planning-artifact update before finishing.

## Step 8: Present the result to the user

Summarize:
1. files changed
2. acceptance criterion covered
3. validation run and result
4. story progress updates applied in `story-<story-number>.md`
5. planning updates applied
6. remaining blockers, follow-ups, or risks
7. whether another criterion is now unblocked

Ask the user to review the implementation before running another `/a-criterion`.

## Success Criteria

- [ ] the selected acceptance criterion was located from `story-<story-number>.md`
- [ ] the selected acceptance criterion number matched a dedicated implementation-plan section in `story-<story-number>.md`
- [ ] all required inputs and followed references were validated before implementation continued
- [ ] only the selected acceptance criterion's scope was implemented
- [ ] changed files follow existing local patterns and canonical glossary naming
- [ ] focused validation ran, or the lack of automation was explained explicitly
- [ ] relevant tests were added or updated when a matching test pattern exists
- [ ] relevant UI references were loaded before implementing UI behavior
- [ ] internal implementation tasks were treated as guidance for the selected criterion, not as separate command targets
- [ ] the selected criterion's checklist state was updated only in `story-<story-number>.md`
- [ ] the story-level completion marker was checked only if every acceptance criterion in `story-<story-number>.md` is complete
- [ ] any durable glossary or architecture updates were applied deliberately
- [ ] the user reviewed the result before the pipeline advanced

## Error Handling

- **Missing criterion selector** — ask the user to provide `<story-number>-<criterion-number>`
- **Empty epic argument with no usable `./planning/current.json` fallback** — ask the user to provide `<epic-slug>`
- **Invalid `./planning/current.json`** — report the exact issue with the missing or malformed `epic-slug` field and stop
- **Invalid selector format** — explain the expected format `<story-number>-<criterion-number>` and stop
- **Missing `story-<story-number>.md`** — report the exact path checked and tell the user to run `/a-story <epic-slug> <story-number>`
- **Missing `architecture.plan.md`** — report the exact path checked and tell the user to run `/a-architecture <epic-slug>`
- **Missing `glossary.md`** — tell the user to run `/a-global-architecture` first
- **Missing or unreadable followed reference** — report the exact reference and originating file and stop instead of skipping it
- **Acceptance criterion not found** — list available acceptance-criterion numbers from the story file and ask the user to pick one
- **Malformed criterion plan** — report that the selected acceptance criterion in `story-<story-number>.md` is missing its required implementation-plan structure instead of reconstructing it from surrounding prose
- **Missing story status marker** — add the canonical `## Status` section to `story-<story-number>.md` before writing the final completion state
- **Unsatisfied dependency** — report the dependency and stop before editing code
- **Criterion/architecture/codebase conflict** — surface the conflict clearly and ask the user before widening scope
- **Validation blocked by unrelated existing failure** — report the exact command, the failure, and why it is out of scope
- **Merge conflicts encountered** — invoke `conflict-resolution`, resolve carefully, verify the result, and then continue only if criterion scope is still intact
