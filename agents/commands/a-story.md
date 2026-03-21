---
description: Break down a single story into a detailed implementation plan organized by acceptance criterion
argument-hint: "<story-number> [\"instructions-or-suggestions\"]"
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Skill]
---

# Story Breakdown

This command is a single step of a longer pipeline:
```text
a-epic -> a-architecture -> a-story(s) -> a-criterion(s)
                                ^current
```
Next: `/a-criterion` consumes the numbered acceptance criteria and implementation plan produced by this command

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | `./planning/<epic-slug>/epic.md` | User stories, story-level context and dependencies, and epic-level UI references from `/a-epic` |
| **In** | `./planning/<epic-slug>/architecture.plan.md` | Epic-specific architecture from `/a-architecture` |
| **In** | `./planning/<epic-slug>/personas.md` | Personas from `/a-epic` |
| **In/Out** | `./planning/glossary.md` | Shared domain glossary from `/a-global-architecture` |
| **In/Out** | `./planning/global-architecture.plan.md` | Shared repo-wide architecture from `/a-global-architecture` |
| **Out** | `./planning/<epic-slug>/story-<story-number>.md` | Detailed story breakdown for this story, including story-level completion status, numbered acceptance criteria, story-relevant UI references, and the implementation plan that `/a-criterion` reads and updates |

## Skills

Invoke these skills when relevant:
- `ux-laws` for stories with UI
- `react-best-practices` when the project uses React
- `typescript-best-practices` when the project uses TypeScript
- `web-design-guidelines` when the story includes web UI
- All relevant project specific rules and skills

## Purpose

Break one story into a concrete, code-informed implementation plan without writing code. This command should:
- investigate the current codebase
- draft and refine acceptance criteria with the user before locking them into the story artifact
- define reuse opportunities and constraints
- refine story-level details when needed
- capture schema-impact context when the story changes persisted data
- produce a single story artifact with numbered acceptance criteria and implementation-plan tasks for `/a-criterion`

## Rules

- NEVER write or modify application code, create commits, or write files outside `./planning/`
- NEVER skip codebase investigation; task planning must be grounded in the real codebase
- NEVER define synonyms; if a term exists in the glossary, use its canonical name
- NEVER abbreviate new names
- NEVER propose extractions for hypothetical future use
- NEVER write unnumbered acceptance criteria; `/a-criterion` depends on stable criterion numbers
- NEVER finalize the acceptance-criteria list without explicit user approval for each criterion in order
- NEVER let implementation tasks float without a clear acceptance-criterion parent
- NEVER split implementation tasks by technology layer alone when one coherent story-slice task would be clearer
- refine higher-level artifacts only when the finding is durable and useful beyond this one local note
- If trailing guidance is provided, treat it as the highest-priority refinement input for this run. It may clarify scope, request plan changes, or include partial implementation direction, but it must not silently override the required story selector, glossary canon, validated references, or other hard command constraints

## Step 1: Resolve required inputs

`$ARGUMENTS` = `<story-number> [instructions-or-suggestions]`

Interpret argument shapes like this:
- this command accepts exactly one explicit argument: `<story-number>`
- any remaining text after `<story-number>` is optional high-priority guidance for this run
- epic selection is not accepted as a command argument

Examples:
- `/a-story 2` -> use the current epic and story `2`
- `/a-story 2 "Keep the existing webhook ingestion path and update the story plan around it"` -> use the current epic and story `2`, and treat the quoted text as highest-priority guidance

If `<story-number>` is empty or missing, stop and ask the user to provide it. Do not guess or continue with partial context.

If guidance text is present after `<story-number>`, treat it as the highest-priority refinement input for this run.

Guidance may include:
- clarifications
- changes to the story plan
- corrections to stale planning assumptions
- partial implementation notes that should shape the plan when validated

Use that guidance ahead of default planning heuristics and stale assumptions, but do not let it silently override the required story selector, `./planning/current.json`, followed references, or stronger source-of-truth evidence.

Resolve `<epic-slug>` from `./planning/current.json` field `epic-slug`.

If `./planning/current.json` does not provide `<epic-slug>`, stop and report the exact problem. Do not guess or continue with partial context.

Read:
- `./planning/<epic-slug>/epic.md`
- `./planning/<epic-slug>/architecture.plan.md`
- `./planning/<epic-slug>/personas.md`
- `./planning/glossary.md`
- `./planning/global-architecture.plan.md`

If `glossary.md` or `global-architecture.plan.md` is missing, stop and tell the user to run `/a-global-architecture` first.

If `epic.md`, `architecture.plan.md`, or `personas.md` is missing, stop and report the exact path checked.

If `./planning/current.json` is unreadable, malformed, or missing `epic-slug`, report that exact problem and stop.

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

## Step 2: Draft acceptance criteria with the user

Use the selected story's canonical statement from `epic.md`, its user context, dependencies, personas, and any trailing guidance to propose the story's working acceptance criteria list.

Draft them interactively:
1. propose exactly one numbered acceptance criterion at a time, starting with `1`
2. ask the user to approve or revise that specific criterion before proposing the next one
3. if the user revises a criterion, fold the revision into the wording and confirm it before continuing
4. do not draft criterion `N + 1` until criterion `N` is explicitly approved
5. keep the numbering stable once a criterion is approved; if a later change forces renumbering, stop and get explicit user confirmation for the renumbered list

While drafting:
- split overly broad source criteria into multiple numbered criteria when that improves implementation clarity
- merge duplicate or overlapping source criteria when the user agrees
- keep criteria implementation-relevant and testable, but do not turn them into tasks
- preserve glossary-canonical naming

After the last criterion is approved, restate the full numbered list and treat it as the locked acceptance-criteria source for the rest of the command.

## Step 3: Investigate the codebase

Use `global-architecture.plan.md` and `architecture.plan.md` to scope targeted code exploration to achieve the story acceptance criteria.

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

If the story affects persisted schema, also identify:
- affected entities or tables
- relationships relevant to the story
- fields that are new, changed, or deleted
- unchanged fields that are still relevant to the story's implementation or review

Display the findings before proceeding.

## Step 4: Check consistency

Based on the investigation, evaluate:
1. naming conventions
2. file placement conventions
3. API and service patterns
4. component patterns
5. test patterns
6. type and contract patterns

Flag inconsistencies that matter to this story. Do not fix unrelated issues.

## Step 5: Define UX

If the story has UI, use `ux-laws` and define:
- user flow
- states
- feedback
- accessibility requirements

Use the followed UI references to ground those decisions. Do not invent UI behavior that contradicts the referenced design artifacts unless the conflict is surfaced explicitly.

If there is no UI, explicitly note that UX/UI sections are skipped.

## Step 6: Define UI

If the story has UI, define:
- component inventory
- hierarchy
- important props and state boundaries
- styling approach
- responsive behavior

If there is no UI, explicitly note that UI sections are skipped.

## Step 7: Define opportunities for code extraction and reusability

Identify justified extractions:
- shared components
- shared utilities
- shared types
- necessary refactors

Only include extractions that are clearly warranted by this story.

## Step 8: Refine upstream artifacts when needed

_With user permission_, this command may update higher-level artifacts when deeper investigation uncovers durable knowledge:
- update `epic.md` when the story wording, boundaries, sequencing, or dependencies need correction
- update `architecture.plan.md` when story work reveals epic-specific technical details other stories should inherit
- update `glossary.md` when durable domain names, code names, sources, or statuses are confirmed
- update `global-architecture.plan.md` only when the work reveals durable cross-epic structure

Summarize every such update in the output.

## Step 9: Write `story-<story-number>.md`

Write `./planning/<epic-slug>/story-<story-number>.md` with this structure:

This file is the single source of truth for the story. It captures story context, codebase findings, UX, UI, references, the required story diagrams, justified extractions, a story-level completion marker, the user-approved numbered acceptance criteria, and the implementation plan that `/a-criterion` reads and updates.

```md
# Story <story-number>: <title>

> Epic: <epic name>
> Generated: <date>
> Source Story: `./planning/<epic-slug>/epic.md`

_As a_ [role], _I want_ [action], _so that_ [benefit].

## Status
- [ ] Story complete

## User Context
- ...

## Acceptance Criteria
1. [ ] ...
2. [ ] ...

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

### ASCII UI Sketch
- If the story has UI, include a compact ASCII drawing that shows the primary layout, key controls, important content regions, and main interaction affordances
- Keep it implementation-oriented and readable in plain text; use labels that match the story terminology and followed UI references
- If the story does not have UI, write `- None`

```text
+--------------------------------------------------+
| Story Screen Title                               |
+--------------------------------------------------+
| Filter / Search: [______________]   [Action Btn] |
+--------------------------+-----------------------+
| Navigation / List        | Primary Content Area  |
| - Item A                 | - Key field           |
| - Item B                 | - Status              |
| - Item C                 | - Secondary actions   |
+--------------------------+-----------------------+
| Feedback / validation / empty-state messaging    |
+--------------------------------------------------+
```

## UI References
- Story-relevant subset of the epic-level UI references, plus any story-local UI references followed during this run
- If none exist, write `- None`

## Diagrams
Present these diagrams in this exact order:
1. Flow Diagram
2. Class Diagram
3. Sequence Diagram

### Flow Diagram
- Include a Mermaid `flowchart` that shows the story's end-to-end user and system flow
- Show the main happy path plus key decision branches, failures, and handoffs that matter to implementation review
- Keep it scoped to this story only

```mermaid
flowchart TD
    Start([User starts story flow]) --> StepA[Primary user action]
    StepA --> Decision{Valid?}
    Decision -->|Yes| StepB[System completes key operation]
    Decision -->|No| Error[System shows recoverable error]
    StepB --> End([Story outcome achieved])
    Error --> End
```

### Class Diagram
- Include a Mermaid `classDiagram` that shows only the story-relevant entities, tables, value objects, or components and their relationships
- Show each entity once using its DB representation only; do not duplicate the same entity across tech stacks (e.g., do not show both a DB table and a TS interface for the same concept)
- If the story changes persisted schema, explicitly mark changed fields inline using `((NEW))`, `((CHANGED))`, or `((DELETED))`
- Include unchanged fields only when they are relevant for understanding the story
- If the story does not change persisted schema, still include the story-relevant domain or structural relationships rather than writing `None`

```mermaid
classDiagram
    class ExampleEntity {
        id: uuid
        existing_field: text
        new_field ((NEW)): text
        renamed_field ((CHANGED)): text
        legacy_field ((DELETED)): text
    }
```

### Sequence Diagram
- Include a Mermaid `sequenceDiagram` that shows the story's runtime interactions across tech layers
- Participants (top row) must be real code entities: components, hooks, services, API controllers, repositories, external systems — not abstract roles
- Group participants by tech layer so the boundaries are visually obvious (e.g., UI | API | Domain | DB)
- Arrow labels must use the actual method signature or API call definition (e.g., `getUserById(id)`, `GET /admin/users?filter[active]=true`, `SELECT * FROM users WHERE active`)
- Show the happy path first, then key alt/opt blocks for errors or edge cases
- Keep it scoped to this story only

```mermaid
sequenceDiagram
    participant UI as UserList (React)
    participant Hook as useUsers (hook)
    participant API as UsersController
    participant Svc as UserService
    participant DB as users (table)

    UI->>Hook: mount / filter change
    Hook->>API: GET /admin/users?filter[active]=true
    API->>Svc: findUsers(filter)
    Svc->>DB: SELECT id, name, email FROM users WHERE active = true
    DB-->>Svc: rows
    Svc-->>API: User[]
    API-->>Hook: 200 { data: User[] }
    Hook-->>UI: re-render list

    alt User not found
        API-->>Hook: 404 { error: "No users match filter" }
        Hook-->>UI: show empty state
    end
```

## Codebase Context
### Related Code
- ...

### Patterns To Follow
- ...

### Reuse Opportunities
- ...

## Consistency Notes
- ...

### Extractions
| What | From/Why | Target Location | Blocks Story? |
| ---- | -------- | --------------- | ------------- |

## Implementation Plan
### Acceptance Criterion 1

> _Given_ [precondition]
> _When_ [action]
> _Then_ [expected result]

#### Outcome
- Describe what must be true when this criterion is complete

#### Files Likely To Change
- `path/a`

#### Dependencies
- none

#### Implementation Tasks
- [ ] Task 1.1: <imperative title>
  **Type**: [component | hook | service | api | model | migration | test | config | refactor]
  **Files**: `path/a`, `path/b`
  **Description**: ...
  **Notes**: ...

### Acceptance Criterion 2

> **Given** ...
> **When** ...
> **Then** ...

#### Outcome
- ...

#### Files Likely To Change
- ...

#### Dependencies
- `1` | `Story <other-story-number>` | none

#### Implementation Tasks
- [ ] Task 2.1: ...

## Upstream Updates Applied
- ...

## References
- `./planning/<epic-slug>/architecture.plan.md`
- `./planning/global-architecture.plan.md`
```

Rules for the implementation plan:
- acceptance criteria must stay explicitly numbered, because `/a-criterion` selects by criterion number
- include a `## Status` section with `- [ ] Story complete`; `/a-criterion` owns updating it after implementation runs
- every `### Acceptance Criterion N` section must match an item in `## Acceptance Criteria`
- implementation tasks must be nested under their acceptance criterion and must never be mistaken for command selectors
- implementation tasks may be story-coherent rather than artificially isolated
- if a criterion needs a new type, validation, or helper to satisfy the slice, include it there instead of splitting it into a separate pseudo-task by default
- keep schema details in `## Diagrams` under `### Class Diagram`, not scattered across implementation-task prose, unless a task needs to call out a migration-specific nuance

## Step 10: Present to user

Summarize:
1. number of acceptance criteria
2. critical path
3. reuse opportunities
4. upstream updates applied
5. risks and open questions
6. recommended starting criterion

Ask the user to review the completed story artifact before moving to `/a-criterion`. Do not ask for fresh acceptance-criteria drafting at this stage unless the user wants to reopen one of the already approved criteria.

## Success Criteria

- [ ] `story-<story-number>.md` exists
- [ ] all required inputs and followed references were validated before story planning continued
- [ ] `story-<story-number>.md` contains numbered acceptance criteria
- [ ] each acceptance criterion was explicitly approved by the user before the next criterion was drafted
- [ ] acceptance criteria cover the story's happy path plus important errors, failures, and security constraints
- [ ] `story-<story-number>.md` contains a `## Status` section with `- [ ] Story complete`
- [ ] every acceptance criterion has a matching `### Acceptance Criterion N` section in `## Implementation Plan`
- [ ] implementation tasks are clearly nested under their acceptance criterion and cannot be confused with the `/a-criterion` selector
- [ ] implementation tasks are organized around coherent story-slice delivery, not just technology-layer isolation
- [ ] UI stories include a `### ASCII UI Sketch` section with a readable plain-text layout sketch; non-UI stories explicitly write `- None`
- [ ] story-relevant UI references were carried into `story-<story-number>.md`, or `- None` was written explicitly
- [ ] `story-<story-number>.md` contains a `## Diagrams` section with `### Flow Diagram`, `### Class Diagram`, and `### Sequence Diagram` in that exact order
- [ ] the flow diagram uses Mermaid `flowchart` syntax and covers the story's user and system path
- [ ] the class diagram uses Mermaid `classDiagram` syntax and covers the story-relevant structure using DB representation only (no TS duplicates); schema-changing stories include field-level `((NEW))`, `((CHANGED))`, and `((DELETED))` markers
- [ ] the sequence diagram uses Mermaid `sequenceDiagram` syntax with real code entities as participants, grouped by tech layer, and uses actual method signatures and API call definitions on arrows
- [ ] any durable naming updates were propagated to `glossary.md`
- [ ] any durable cross-epic structure updates were propagated to `global-architecture.plan.md`
- [ ] the user reviewed the output before the pipeline advanced

## Error Handling

- **Missing story number** — ask the user to provide a story number
- **Epic selection attempted in guidance** — explain that `/a-story` always uses `./planning/current.json` for epic selection; keep the resolved `<story-number>` and treat any remaining text as high-priority guidance only
- **Invalid `./planning/current.json`** — report the exact issue with the missing or malformed `epic-slug` field and stop
- **Story not found in `epic.md`** — list available story numbers and ask the user to pick one
- **Missing shared repo files** — tell the user to run `/a-global-architecture` first
- **Missing epic-specific files** — report the exact missing path and tell the user which earlier command to run
- **Missing or unreadable followed reference** — report the exact reference and originating file and stop instead of skipping it
- **No relevant code found** — say so explicitly and treat the story as a greenfield area while still following project-wide patterns
