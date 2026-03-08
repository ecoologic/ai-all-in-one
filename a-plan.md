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

`a-global-architecture` is the prerequisite repo-wide context step. It is run before epic planning begins, and again later whenever durable shared structure or domain language changes enough that the shared artifacts need refresh.

## Artifact Layout

All planning artifacts use relative paths rooted at `tmp/planning/`.
Gitignore `tmp` and make a new repo in the planning folder, plans stay separate from the codebase.

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

### `/a-global-architecture`

Reads:
- codebase (read-only)
- repo docs and durable product/architecture references

Writes:
- `tmp/planning/global-architecture.md`
- `tmp/planning/glossary.md`

Updates:
- both files whenever durable cross-epic structure or shared domain language changes

Notes:
- this command owns the shared repo-wide artifacts
- later commands may refine those artifacts when they discover durable knowledge
- downstream commands should assume both files exist because this command is the prerequisite that creates them

### `/a-epic <epic-slug>`

The list of user stories and the personas that will be used to build the product. It's detached from the codebase, we're still defining what we want to build. No need to design architecture until we have decided what to build.

Reads:
- `tmp/planning/<epic-slug>/idea.md`
- `tmp/planning/glossary.md`
- `tmp/planning/global-architecture.md`

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
- if the shared repo-wide artifacts are missing, run `/a-global-architecture` first

### `/a-architecture <epic-slug>`

Design the technical architecture changes for an epic based on the existing code. Tasks will read this to have a shared understanding how to build the product. And will need less repeated investigation.

Reads:
- `tmp/planning/<epic-slug>/idea.md`
- `tmp/planning/<epic-slug>/epic.md`
- `tmp/planning/<epic-slug>/personas.md`
- `tmp/planning/glossary.md`
- `tmp/planning/global-architecture.md`
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

Break down a single story into a detailed implementation plan and task list.

Reads:
- `tmp/planning/<epic-slug>/epic.md`
- `tmp/planning/<epic-slug>/architecture.md`
- `tmp/planning/<epic-slug>/personas.md`
- `tmp/planning/glossary.md`
- `tmp/planning/global-architecture.md`
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

We're finally coding. Now we know what and how to build.

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

### Artifact Ownership And Promotion

Every planning artifact has a primary owner command:

- `a-global-architecture` owns `tmp/planning/global-architecture.md`
- `a-global-architecture` owns `tmp/planning/glossary.md`
- `a-epic` owns `tmp/planning/<epic-slug>/epic.md`
- `a-epic` owns `tmp/planning/<epic-slug>/personas.md`
- `a-architecture` owns `tmp/planning/<epic-slug>/architecture.md`
- `a-story` owns `tmp/planning/<epic-slug>/story-<story-number>.md`
- `a-story` owns `tmp/planning/<epic-slug>/story-<story-number>-tasks.md`
- `a-task` owns code changes

Later commands may refine higher-level artifacts when they discover durable knowledge. This is an allowed part of the workflow, not an exception.

Allowed promotion targets:

- update `epic.md` when deeper work sharpens story wording, boundaries, sequencing, or prerequisites
- update `architecture.md` when story or task work reveals epic-specific technical truth that other stories should inherit
- update `glossary.md` when a durable domain term, code name, source, or status is confirmed
- update `global-architecture.md` only when work reveals durable cross-epic structure, boundaries, contracts, or communication paths

Not allowed:

- pushing temporary task notes into shared artifacts
- promoting speculative future abstractions
- treating story-local implementation detail as repo-wide architecture
- rewriting higher-level artifacts without a durable reason

When a command updates a higher-level artifact, it must summarize what changed and why before the pipeline advances.

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

`tmp/planning/glossary.md` should stay domain-based and cross-epic.

It may include:
- stable domain terms
- canonical names used across planning and implementation
- confirmed code names, sources, and statuses

It must not accumulate:
- temporary aliases
- speculative future terminology
- story-local wording that is not durable

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
- `a-story` discovers the current story should be split differently and updates `epic.md`
- `a-story` discovers architecture details that belong in `architecture.md` for other stories to use
- `a-story` or `a-task` discovers durable domain names that belong in `glossary.md`
- `a-architecture`, `a-story`, or `a-task` discovers durable high-level cross-epic structure that belongs in `global-architecture.md` (particularly when the code proves the file is outdated)

Not allowed:
- pushing temporary task-level implementation noise into shared artifacts
- rewriting higher-level docs without a durable reason

### User Checkpoints

Every `a-` command must present results to the user and get confirmation before the pipeline moves to the next step. No command auto-chains into the next.
