# Agile Planning Pipeline

## Problem

- Planning starts from an incomplete idea, noisy inputs, and premature assumptions.
  - Planning is hard. It starts with a foggy idea, and lots of misinformation. We need to work towards the best solution and UX for our users, we don't know yet what we want

- Without an overarching system of information, separate tasks to deliver the initial idea can be inconsistent and deliver non-cohesive behavior
  - If AI breaks work down without shared context, the resulting stories and tasks can drift apart and produce non-cohesive behavior.
- Large PRs and tech-stack-based breakdowns are hard to review because the reviewer cannot see the full product and architecture intent.
  - PRs are way too big, and work that's broken down by tech stack is not deliverable in isolation, and it's harder for the reviewer to critique it without the full picture

## Goal

Create a set of `a-` commands that progressively turn an idea into small implementation tasks with strong naming, architecture, and review discipline. AI does the drafting work, but the user reviews and approves each stage before the pipeline advances.

## Default Flow

```text
a-epic -> a-architecture -> a-story(s) -> a-task(s)
```

## Repo-Wide Context

```text
a-global-architecture (separate, occasional, cross-epic)
```

`a-global-architecture` is not part of the normal per-epic sequence. It is a repo-wide mapping command that may be run once at the start, or later when durable system structure changes or when the repo map is missing/stale.

## Artifact Layout

All planning artifacts use relative paths rooted at `tmp/planning/`.

- Shared across epics:
  - `tmp/planning/glossary.md`
  - `tmp/planning/global-architecture.md`
- Per epic:
  - `tmp/planning/<epic-slug>/idea.md`
  - `tmp/planning/<epic-slug>/epic.md`
  - `tmp/planning/<epic-slug>/personas.md`
  - `tmp/planning/<epic-slug>/architecture.md`
  - `tmp/planning/<epic-slug>/story-<n>.md`
  - `tmp/planning/<epic-slug>/story-<n>-tasks.md`

The `epic-slug` is part of the command input and must match the folder under `tmp/planning/`.

## Command Contracts

### `/a-epic <epic-slug>`

Reads:
- `tmp/planning/<epic-slug>/idea.md`
- `tmp/planning/glossary.md` if present

Writes:
- `tmp/planning/<epic-slug>/epic.md`
- `tmp/planning/<epic-slug>/personas.md`

Updates:
- `tmp/planning/glossary.md` when new durable product terms are introduced

Notes:
- `idea.md` is read-only input.
- `idea.md` may reference any supporting materials such as UI, product notes, or research docs.
- `epic.md` contains the story list and initial story framing.
- `personas.md` is a separate artifact, but it is produced as part of `/a-epic` rather than by its own command.

### `/a-architecture <epic-slug>`

Reads:
- `tmp/planning/<epic-slug>/idea.md`
- `tmp/planning/<epic-slug>/epic.md`
- `tmp/planning/<epic-slug>/personas.md`
- `tmp/planning/glossary.md`
- codebase (read-only)

Writes:
- `tmp/planning/<epic-slug>/architecture.md`

Updates:
- `tmp/planning/glossary.md` when codebase investigation reveals durable code names, sources, statuses, or terms worth standardizing
- `tmp/planning/global-architecture.md` only when the command uncovers durable cross-epic structure that belongs in the repo map, not epic specific

Notes:
- In the normal epic pipeline, `a-architecture` is the first epic-specific command that may read the codebase.
- This does not conflict with `a-global-architecture`, which is a separate repo-wide mapping command.

### `/a-story <epic-slug> <story-number>`

Reads:
- `tmp/planning/<epic-slug>/epic.md`
- `tmp/planning/<epic-slug>/architecture.md`
- `tmp/planning/<epic-slug>/personas.md`
- `tmp/planning/glossary.md`
- `tmp/planning/global-architecture.md` if present
- codebase (read-only)

Writes:
- `tmp/planning/<epic-slug>/story-<story-number>.md`
- `tmp/planning/<epic-slug>/story-<story-number>-tasks.md`

Edits:
- `tmp/planning/<epic-slug>/epic.md` when detailed story work sharpens the story definition
- `tmp/planning/<epic-slug>/architecture.md` when story-level investigation reveals architecture details that should be captured upstream

Updates:
- `tmp/planning/glossary.md` when investigation reveals durable names or source mappings worth preserving
- `tmp/planning/global-architecture.md` only when story work reveals durable cross-epic structure

### `/a-task <epic-slug> <story-number>-<task-number>`

Reads:
- `tmp/planning/<epic-slug>/story-<story-number>-tasks.md`
- `tmp/planning/<epic-slug>/architecture.md`
- `tmp/planning/<epic-slug>/story-<story-number>.md` if needed
- `tmp/planning/glossary.md`
- codebase

Writes:
- codebase

Edits:
- planning artifacts only when implementation reveals durable knowledge that should be captured for future work

## Shared Rules

All `a-` commands must follow these rules. Each command should inline the relevant parts so it can run as a self-contained instruction set.

### Pipeline I/O

Each command declares a Pipeline I/O table in its header.

`tmp/planning/glossary.md` is always available as `In/Out`, but it should only be updated when a command discovers a durable domain term worth standardizing.

### Source Of Truth Hierarchy

- Avoid guesswork
- Inferred models are hypotheses until validated
- Existing code and stable project conventions beat prototype structure
- `tmp/planning/global-architecture.md` is the source of truth for durable repo structure and communication paths, unless contradicted by the codebase (which of course is the ultimate source of truth, but not always available)
- `tmp/planning/<epic-slug>/architecture.md` is the source of truth for epic-specific architecture decisions.

### Global Architecture

`tmp/planning/global-architecture.md` should stay lean and cross-epic.

It may include:
- stable modules, boundaries, and responsibilities
- durable communication paths such as `ui -> api`, `api -> db`, jobs, queues, webhooks, edge functions, and external services
- stable contracts that matter across multiple epics
- how the major parts communicate

It must not accumulate:
- current-epic rationale
- story-specific design details
- Assumptions of any type

### Naming

- Never define synonyms. If a term exists in the glossary, use its exact Code Name everywhere.
- Never abbreviate names. Use the domain's exact terms (`team-management`, not `team-mgmt`; `Invitation`, not `Invite`).
- Slugs use full words separated by hyphens.

### Scope Boundaries

- No planning command before `a-task` may write or modify application code.
- No planning artifact may be written outside `tmp/planning/`.
- `a-task` is the only command that may write to the codebase.
- `a-task` may run only after the user has approved the relevant planning artifacts.
- Never propose extractions for hypothetical future use (YAGNI).

### Upward Propagation

Detailed work is allowed to refine higher-level artifacts when it uncovers durable knowledge.

Allowed examples:
- `a-story` discovers architecture details that belong in `architecture.md` for other stories to use
- `a-story` or `a-task` discovers durable domain names that belong in `glossary.md`
- `a-architecture`, `a-story`, or `a-task` discovers durable high-level cross-epic structure that belongs in `global-architecture.md` (particularly when the code proves the fiile is outdated)

Not allowed:
- pushing temporary task-level implementation noise into shared artifacts
- rewriting higher-level docs without a durable reason

### User Checkpoints

Every `a-` command must present results to the user and get confirmation before the pipeline moves to the next step. No command auto-chains into the next.
