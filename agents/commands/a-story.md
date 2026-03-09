---
description: Break down a single story into a detailed implementation plan and task list
argument-hint: <epic-slug> <story-number>
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Skill]
---

# Story Breakdown

This command is a single step of a longer pipeline:
```text
a-epic -> a-architecture -> a-story(s) -> a-task(s)
                         ^current
```
Next: `/a-task` consumes the task list produced by this command

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | `./tmp/planning/<epic-slug>/epic.md` | User stories and epic-level UI references from `/a-epic` |
| **In** | `./tmp/planning/<epic-slug>/architecture.md` | Epic-specific architecture from `/a-architecture` |
| **In** | `./tmp/planning/<epic-slug>/personas.md` | Personas from `/a-epic` |
| **In/Out** | `./tmp/planning/glossary.md` | Shared domain glossary from `/a-global-architecture` |
| **In/Out** | `./tmp/planning/global-architecture.md` | Shared repo-wide architecture from `/a-global-architecture` |
| **Out** | `./tmp/planning/<epic-slug>/story-<story-number>.md` | Detailed story breakdown for this story, including story-relevant UI references |
| **Out** | `./tmp/planning/<epic-slug>/story-<story-number>-tasks.md` | Ordered task list that `/a-task` reads |

## Skills

Invoke these skills when relevant:
- `ux-laws` for stories with UI
- `react-best-practices` when the project uses React
- `typescript-best-practices` when the project uses TypeScript
- `web-design-guidelines` when the story includes web UI

## Purpose

Break one story into a concrete, code-informed implementation plan without writing code. This command should:
- investigate the current codebase
- define reuse opportunities and constraints
- refine story-level details when needed
- produce a clean task list for `/a-task`

## Rules

- NEVER write or modify application code, create commits, or write files outside `./tmp/planning/`
- NEVER skip codebase investigation; task planning must be grounded in the real codebase
- NEVER define synonyms; if a term exists in the glossary, use its canonical name
- NEVER abbreviate new names
- NEVER propose extractions for hypothetical future use
- NEVER produce multi-concern tasks; each task should have one primary concern
- refine higher-level artifacts only when the finding is durable and useful beyond this one local note

## Step 1: Resolve required inputs

`$ARGUMENTS` = `<epic-slug> <story-number>`

If either `<epic-slug>` or `<story-number>` is empty or missing, stop and ask the user to provide both values. Do not guess or continue with partial context.

Read:
- `./tmp/planning/<epic-slug>/epic.md`
- `./tmp/planning/<epic-slug>/architecture.md`
- `./tmp/planning/<epic-slug>/personas.md`
- `./tmp/planning/glossary.md`
- `./tmp/planning/global-architecture.md`

If `glossary.md` or `global-architecture.md` is missing, stop and tell the user to run `/a-global-architecture` first.

If `epic.md`, `architecture.md`, or `personas.md` is missing, stop and report the exact path checked.

Also follow references from every planning artifact read in this step. Treat each followed reference as required input for this run. If any followed reference cannot be found, accessed, or read, stop and report the exact reference and the file that referenced it.

When `epic.md` contains a `UI References` section, treat those references as required input for this run. Read and follow them before planning any story that has UI or depends on UI behavior.

Extract the requested story section from `epic.md`. The story context includes:
- title
- canonical story statement
- user context
- acceptance criteria
- dependencies

Also extract the epic-level sections from `epic.md` that apply across stories:
- draft ERD
- requirements
- UX considerations
- UI references
- references

Output:
```text
Story: <title>
Epic: <epic name>
Architecture: loaded
Personas: loaded
Epic-level context: loaded
Has UI: <yes | no>
UI references: <list or none>
```

## Step 2: Investigate the codebase

Use `global-architecture.md` and `architecture.md` to scope targeted code exploration.

Use targeted search and explore agents to gather:
1. related existing code
2. patterns and conventions
3. reuse opportunities

Each investigation result should report:
- relevant files
- why they matter
- patterns to follow
- reusable components, services, types, or utilities
- naming matches or conflicts with the glossary

Display the findings before proceeding.

## Step 3: Check consistency

Based on the investigation, evaluate:
1. naming conventions
2. file placement conventions
3. API and service patterns
4. component patterns
5. test patterns
6. type and contract patterns

Flag inconsistencies that matter to this story. Do not fix unrelated issues.

## Step 4: Define UX

If the story has UI, use `ux-laws` and define:
- user flow
- states
- feedback
- accessibility requirements

Use the followed UI references to ground those decisions. Do not invent UI behavior that contradicts the referenced design artifacts unless the conflict is surfaced explicitly.

If there is no UI, explicitly note that UX/UI sections are skipped.

## Step 5: Define UI and extraction opportunities

If the story has UI, define:
- component inventory
- hierarchy
- important props and state boundaries
- styling approach
- responsive behavior

Then identify justified extractions:
- shared components
- shared utilities
- shared types
- necessary refactors

Only include extractions that are clearly warranted by this story.

## Step 6: Refine upstream artifacts when needed

This command may update higher-level artifacts when deeper investigation uncovers durable knowledge:
- update `epic.md` when the story wording, boundaries, sequencing, or dependencies need correction
- update `architecture.md` when story work reveals epic-specific technical details other stories should inherit
- update `glossary.md` when durable domain names, code names, sources, or statuses are confirmed
- update `global-architecture.md` only when the work reveals durable cross-epic structure

Summarize every such update in the output.

## Step 7: Write `story-<story-number>.md`

Write `./tmp/planning/<epic-slug>/story-<story-number>.md` with this structure:

```md
# Story <story-number>: <title>

> Epic: <epic name>
> Generated: <date>
> Source Story: `./tmp/planning/<epic-slug>/epic.md`

_As a_ [role], _I want_ [action], _so that_ [benefit].

## User Context
- ...

## Acceptance Criteria
1. [ ] ...

## Codebase Context
### Related Code
- ...

### Patterns To Follow
- ...

### Reuse Opportunities
- ...

## Consistency Notes
- ...

## UX Definition
### User Flow
1. ...

### States
| State | Description | UI Behavior |
| ----- | ----------- | ----------- |

### Accessibility
- ...

## UI Definition
### Component Inventory
| Component | New/Existing | Location |
| --------- | ------------ | -------- |

### Component Hierarchy
- ...

## UI References
- Story-relevant subset of the epic-level UI references, plus any story-local UI references followed during this run
- If none exist, write `- None`

## Extractions
| What | From/Why | Target Location | Blocks Story? |
| ---- | -------- | --------------- | ------------- |

## Upstream Updates Applied
- ...

## References
- `./tmp/planning/<epic-slug>/architecture.md`
- `./tmp/planning/global-architecture.md`
```

## Step 8: Write `story-<story-number>-tasks.md`

Write `./tmp/planning/<epic-slug>/story-<story-number>-tasks.md` as the single source of truth for `/a-task`.

Use this structure:

```md
# Story <story-number> Tasks: <title>

> Epic: <epic name>
> Story: `./tmp/planning/<epic-slug>/story-<story-number>.md`
> Generated: <date>

## Task 1: <imperative title>

**Type**: [component | hook | service | api | model | migration | test | config | refactor]
**Files**: `path/a`, `path/b`
**Depends on**: none

**Description**:
...

**Acceptance Criteria**:
- [ ] ...

**Notes**:
- ...

## Task 2: <imperative title>
...
```

Task ordering guidelines:
1. shared types and contracts
2. data layer and migrations
3. business logic
4. UI components
5. integration and wiring
6. tests

## Step 9: Present to user

Summarize:
1. number of tasks
2. critical path
3. reuse opportunities
4. upstream updates applied
5. risks and open questions
6. recommended starting task

Ask the user to review before moving to `/a-task`.

## Success Criteria

- [ ] `story-<story-number>.md` exists
- [ ] `story-<story-number>-tasks.md` exists
- [ ] all required inputs and followed references were validated before story planning continued
- [ ] every task has type, files, dependencies, description, and acceptance criteria
- [ ] task ordering is explicit
- [ ] story-relevant UI references were carried into `story-<story-number>.md`, or `- None` was written explicitly
- [ ] any durable naming updates were propagated to `glossary.md`
- [ ] any durable cross-epic structure updates were propagated to `global-architecture.md`
- [ ] the user reviewed the output before the pipeline advanced

## Error Handling

- **Empty arguments** — ask the user to provide both epic slug and story number
- **Story not found in `epic.md`** — list available story numbers and ask the user to pick one
- **Missing shared repo files** — tell the user to run `/a-global-architecture` first
- **Missing epic-specific files** — report the exact missing path and tell the user which earlier command to run
- **Missing or unreadable followed reference** — report the exact reference and originating file and stop instead of skipping it
- **No relevant code found** — say so explicitly and treat the story as a greenfield area while still following project-wide patterns
