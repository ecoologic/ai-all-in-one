# Agile Planning Pipeline

## TODOs

* The process needs to be way more inteactive
* Stories need a "when shit happens" AC
* Architecture doc needs reviewing

## Problem

- Planning starts from an incomplete idea, noisy inputs, and premature assumptions.
  - Planning is hard. It starts with a foggy idea, and lots of misinformation. We need to work towards the best solution and UX for our users, we don't know yet what we want
- Without an overarching system of information, separate tasks to deliver the initial idea can be inconsistent and deliver non-cohesive behavior
  - If AI breaks work down without shared context, the resulting stories and tasks can drift apart and produce non-cohesive behavior.
- Large PRs and tech-stack-based breakdowns are hard to review because the reviewer cannot see the full product and architecture intent.
  - PRs are way too big, and work that's broken down by tech stack is not deliverable in isolation, and it's harder for the reviewer to critique it without the full picture

## Goal

Create a set of `a-` commands that progressively turn an idea into small implementation slices with strong naming, architecture, and review discipline. AI does the drafting work, but the user reviews and approves each stage before the pipeline advances.

## Default Flow

```text
a-epic -> a-architecture -> a-story(s) -> a-criterion(s)
```

## Revision Companion

```text
a-edit (separate, on demand, feedback-driven)
```

`a-edit` is not a new pipeline stage. It is a companion command used after any planning artifact already exists and needs a targeted correction or refinement based on feedback.

## Repo-Wide Context

```text
a-global-architecture (separate, occasional, cross-epic)
```

`a-global-architecture` is the prerequisite repo-wide context step. It is run before epic planning begins, and again later whenever durable shared structure or domain language changes enough that the shared artifacts need refresh.

## Artifact Layout

All planning artifacts use relative paths rooted at `planning/`.
Plans live in the project root under `planning/`. Gitignore it or make it a separate repo to keep plans separate from the codebase.

- Shared across epics:
  - `planning/current.json`
  - `planning/glossary.md`
  - `planning/global-architecture.md`
- Per epic:
  - `planning/<epic-slug>/idea.md`
  - `planning/<epic-slug>/epic.md`
  - `planning/<epic-slug>/personas.md`
  - `planning/<epic-slug>/stretch-goals.md`
  - `planning/<epic-slug>/architecture.md`
  - `planning/<epic-slug>/story-<n>.md`

`planning/current.json` stores the active epic context for epic-scoped commands. Use this shape:

```json
{
  "epic-slug": "<epic-slug>"
}
```

For epic-scoped commands, resolve the epic slug in this order:
1. explicit command argument
2. `planning/current.json` `epic-slug`

If neither is available, stop and ask the user for the epic slug. The resolved `epic-slug` must match the folder under `planning/`.

## Command Contracts

### `/a-global-architecture`

Reads:
- codebase (read-only)
- repo docs and durable product/architecture references

Writes:
- `planning/global-architecture.md`
- `planning/glossary.md`

Updates:
- both files whenever durable cross-epic structure or shared domain language changes

Notes:
- this command owns the shared repo-wide artifacts
- later commands may refine those artifacts when they discover durable knowledge
- downstream commands should assume both files exist because this command is the prerequisite that creates them

### `/a-epic [epic-slug]`

The list of user stories and the personas that will be used to build the product. It's detached from the codebase, we're still defining what we want to build. No need to design architecture until we have decided what to build.

Reads:
- `planning/<epic-slug>/idea.md`
- `planning/glossary.md`
- `planning/global-architecture.md`

Writes:
- `planning/<epic-slug>/epic.md`
- `planning/<epic-slug>/personas.md`
- `planning/<epic-slug>/stretch-goals.md`

Updates:
- `planning/glossary.md` when new durable product terms are introduced

Notes:
- `idea.md` is read-only input.
- `idea.md` may reference any supporting materials such as UI, product notes, or research docs.
- `epic.md` contains the story list and initial story framing.
- `personas.md` is a separate artifact, but it is produced as part of `/a-epic` rather than by its own command.
- `stretch-goals.md` captures later-scope ideas that stay outside the active pipeline reading path.
- if the shared repo-wide artifacts are missing, run `/a-global-architecture` first

### `/a-architecture [epic-slug]`

Design the technical architecture changes for an epic based on the existing code. Tasks will read this to have a shared understanding how to build the product. And will need less repeated investigation.

Reads:
- `planning/<epic-slug>/idea.md`
- `planning/<epic-slug>/epic.md`
- `planning/<epic-slug>/personas.md`
- `planning/glossary.md`
- `planning/global-architecture.md`
- codebase (read-only)

Writes:
- `planning/<epic-slug>/architecture.md`

Updates:
- `planning/glossary.md` when codebase investigation reveals durable code names, sources, statuses, or terms worth standardizing
- `planning/global-architecture.md` only when the command uncovers durable cross-epic structure that belongs in the repo map, not epic specific

Notes:
- In the normal epic pipeline, `a-architecture` is the first epic-specific command that may read the codebase.
- This does not conflict with `a-global-architecture`, which is a separate repo-wide mapping command.

### `/a-story [epic-slug] <story-number>`

Break down a single story into a detailed implementation plan organized by acceptance criterion.

Reads:
- `planning/<epic-slug>/epic.md`
- `planning/<epic-slug>/architecture.md`
- `planning/<epic-slug>/personas.md`
- `planning/glossary.md`
- `planning/global-architecture.md`
- codebase (read-only)

Writes:
- `planning/<epic-slug>/story-<story-number>.md`

Edits:
- `planning/<epic-slug>/epic.md` when detailed story work sharpens the story definition
- `planning/<epic-slug>/architecture.md` when story-level investigation reveals architecture details that should be captured upstream

Updates:
- `planning/glossary.md` when investigation reveals durable names or source mappings worth preserving
- `planning/global-architecture.md` only when story work reveals durable cross-epic structure

Notes:
- `story-<story-number>.md` is the single source of truth for the story's context, numbered acceptance criteria, and implementation-plan tasks.
- implementation tasks stay grouped under the acceptance criterion they serve.
- task lists should be practical and story-coherent, not artificially split by technology layer or isolation for its own sake.

### `/a-criterion [epic-slug] <story-number>-<criterion-number>`

We're finally coding. Now we know what and how to build.

Reads:
- `planning/<epic-slug>/story-<story-number>.md`
- `planning/<epic-slug>/architecture.md`
- `planning/glossary.md`
- codebase

Writes:
- codebase

Edits:
- planning artifacts only when implementation reveals durable knowledge that should be captured for future work

Notes:
- the selector format stays `<story-number>-<criterion-number>`, but the second number is the numbered acceptance criterion, not an implementation task id.
- internal implementation tasks remain inside `story-<story-number>.md` as execution guidance under each criterion.
- each run completes one acceptance criterion, then stops unless the user explicitly asks to continue.

### `/a-edit <artifact-type> [selector...] <feedback>`

Revise one existing planning artifact in response to user feedback without rerunning the whole owner stage.

Reads:
- the owner command file for the selected artifact type
- the current target artifact
- the owner command's required inputs
- codebase (read-only) only when the owner command is code-informed

Writes:
- the selected target planning artifact

Updates:
- `planning/glossary.md` only when the owner command for the selected artifact would have allowed a durable terminology update
- `planning/global-architecture.md` only when the owner command for the selected artifact would have allowed a durable cross-epic update

Notes:
- `a-edit` is a feedback-driven companion command, not a new pipeline stage
- it must read the original owner command contract before editing
- it must edit exactly one primary planning artifact per run
- supported artifact types are `global-architecture`, `glossary`, `epic`, `personas`, `stretch-goals`, `architecture`, and `story`
- for epic-scoped artifact types, omitted epic selectors may default from `planning/current.json` `epic-slug`
- if feedback is broad enough that a constrained revision would be misleading, rerun the owner command instead

## Shared Rules

All `a-` commands must follow these rules. Each command should inline the relevant parts so it can run as a self-contained instruction set.

### Pipeline I/O

Each command declares a Pipeline I/O table in its header.

`planning/glossary.md` is always available as `In/Out`, but it should only be updated when a command discovers a durable domain term worth standardizing.

Epic-scoped commands also read `planning/current.json` as contextual input when their explicit epic selector is omitted.

### Artifact Ownership And Promotion

Every planning artifact has a primary owner command:

- `a-global-architecture` owns `planning/global-architecture.md`
- `a-global-architecture` owns `planning/glossary.md`
- `a-epic` owns `planning/<epic-slug>/epic.md`
- `a-epic` owns `planning/<epic-slug>/personas.md`
- `a-epic` owns `planning/<epic-slug>/stretch-goals.md`
- `a-architecture` owns `planning/<epic-slug>/architecture.md`
- `a-story` owns `planning/<epic-slug>/story-<story-number>.md`
- `a-criterion` owns code changes
- `a-edit` owns no artifacts; it revises an existing artifact using its owner command's contract

Later commands may refine higher-level artifacts when they discover durable knowledge. This is an allowed part of the workflow, not an exception.

Allowed promotion targets:

- update `epic.md` when deeper work sharpens story wording, boundaries, sequencing, or prerequisites
- update `architecture.md` when story or criterion work reveals epic-specific technical truth that other stories should inherit
- update `glossary.md` when a durable domain term, code name, source, or status is confirmed
- update `global-architecture.md` only when work reveals durable cross-epic structure, boundaries, contracts, or communication paths

Not allowed:

- pushing temporary task notes into shared artifacts
- promoting speculative future abstractions
- treating story-local implementation detail as repo-wide architecture
- rewriting higher-level artifacts without a durable reason

When a command updates a higher-level artifact, it must summarize what changed and why before the pipeline advances.

### Intentional Revision

`a-edit` is the explicit feedback-driven revision path for planning artifacts that already exist.

Rules:
- `a-edit` must read the owner command file before changing the target artifact
- `a-edit` must reread the owner command's required inputs before applying a revision
- `a-edit` edits one primary artifact per run
- `a-edit` should preserve valid existing content and make the smallest durable correction that addresses the feedback
- `a-edit` may update `glossary.md` or `global-architecture.md` only when the owner command for the selected artifact would have allowed that promotion
- `a-edit` must not be used to rewrite the codebase; code changes stay in `a-criterion`
- when a constrained revision would be misleading because the artifact is broadly stale or the feedback changes the stage's core output, rerun the owner command instead

### Source Of Truth Hierarchy

- Avoid guesswork
- Inferred models are hypotheses until validated
- Existing code and stable project conventions beat prototype structure
- `planning/global-architecture.md` is the source of truth for durable repo structure and communication paths, unless contradicted by the codebase (which of course is the ultimate source of truth, but not always available)
- `planning/<epic-slug>/architecture.md` is the source of truth for epic-specific architecture decisions.

### Global Architecture

`planning/global-architecture.md` should stay lean and cross-epic.

It may include:
- stable modules, boundaries, and responsibilities
- durable communication paths such as `ui -> api`, `api -> db`, jobs, queues, webhooks, edge functions, and external services
- stable contracts that matter across multiple epics
- how the major parts communicate

It must not accumulate:
- current-epic rationale
- story-specific design details
- Assumptions of any type

`planning/glossary.md` should stay domain-based and cross-epic.

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

- No planning command before `a-criterion` may write or modify application code.
- No planning artifact may be written outside `planning/`.
- `a-criterion` is the only command that may write to the codebase.
- `a-criterion` may run only after the user has approved the relevant planning artifacts.
- Never propose extractions for hypothetical future use (YAGNI).

### Upward Propagation

Detailed work is allowed to refine higher-level artifacts when it uncovers durable knowledge.

Allowed examples:
- `a-story` discovers the current story should be split differently and updates `epic.md`
- `a-story` discovers architecture details that belong in `architecture.md` for other stories to use
- `a-story` or `a-criterion` discovers durable domain names that belong in `glossary.md`
- `a-architecture`, `a-story`, or `a-criterion` discovers durable high-level cross-epic structure that belongs in `global-architecture.md` (particularly when the code proves the file is outdated)

Not allowed:
- pushing temporary task-level implementation noise into shared artifacts
- rewriting higher-level docs without a durable reason

### Downstream Impact

When a planning artifact is revised, later artifacts may become stale even if they are not rewritten immediately.

Default impact rules:
- editing `global-architecture.md` may affect all epic-specific artifacts
- editing `glossary.md` may affect every artifact that uses the corrected term
- editing `epic.md` may affect `personas.md`, `architecture.md`, and `story-<n>.md` for that epic
- editing `personas.md` may affect `architecture.md` and `story-<n>.md` for that epic
- editing `stretch-goals.md` usually does not affect the active pipeline unless now-work vs later-work boundaries changed
- editing `architecture.md` may affect `story-<n>.md` and future `a-criterion` runs for that epic
- editing `story-<n>.md` may affect future `a-criterion` runs for that story

Every `a-edit` run must include an `Affected artifacts / suggested reruns` summary before the pipeline advances.

### User Checkpoints

Every `a-` command must present results to the user and get confirmation before the pipeline moves to the next step. No command auto-chains into the next.

## Future: QA Pipeline

`a-criterion` (and any steps after it) may discover bugs in code **we wrote** (i.e. code produced by earlier `a-criterion` runs in the same or a previous epic). Ignore issues from features not yet implemented.

When a bug is found, append it to `./planning/<epic-slug>/qa-ideas.md`:

```markdown
- [ ] **<short title>** — <description of the bug and where it was found> (`<file-path>:<line>`)
```

Create the file if it doesn't exist. Never remove existing entries.

Possible dedicated QA commands (not yet implemented):

```
a-unhappy-path -> a-security -> a-bug -> a-qa
```

Or a single `/a-review` that covers all QA aspects.
