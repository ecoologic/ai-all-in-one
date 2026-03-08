---
description: Break down an idea into personas and actionable user stories
argument-hint: <epic-slug>
allowed-tools: [Read, Write, Edit, AskUserQuestion, Skill]
---

# Epic

This command is a single step of a longer pipeline:
```text
a-epic -> a-architecture -> a-story(s) -> a-task(s)
^current
```
Next: `/a-architecture`

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | `./tmp/planning/<epic-slug>/idea.md` | Raw epic idea and links to supporting artifacts |
| **In/Out** | `./tmp/planning/glossary.md` | Shared domain glossary created by `/a-global-architecture` |
| **In** | `./tmp/planning/global-architecture.md` | Shared repo-wide context created by `/a-global-architecture` |
| **Out** | `./tmp/planning/<epic-slug>/epic.md` | Structured story list and initial story framing |
| **Out** | `./tmp/planning/<epic-slug>/personas.md` | Personas, actors, and usage context for later stages |

## Skills

Invoke these skills during execution via `Skill` when relevant:
- `lovable` if `idea.md` or its references point to a Lovable prototype
- `ux-laws` when shaping story boundaries or interaction expectations from the user perspective

## Purpose

Turn a rough idea into a high-quality epic packet for the rest of the pipeline:
- `epic.md` defines the story list and the shape of the work
- `personas.md` captures the actors, goals, and contexts that later commands must inherit

This command produces planning artifacts only. It must not investigate the codebase or write implementation code.

## Rules

- NEVER write or modify application code, create commits, or write files outside `./tmp/planning/`
- NEVER investigate the codebase for this step; rely on `idea.md` and its referenced product artifacts only
- NEVER define synonyms; if a term exists in the glossary, use its exact term everywhere
- NEVER abbreviate new names
- NEVER slice stories by technology layer
- NEVER write implementation details, API shapes, schema designs, or task-level work into `epic.md`
- produce `personas.md` in this command so later stages inherit the same actors and usage context

## What Is A User Story

> A user story is a short, plain-language description of a capability told from the perspective of someone who uses the system, not someone who builds it. It follows the template "As a [persona], I want [goal] so that [benefit]" and describes what the user can do and why it matters, never how it is implemented. Each story should be small enough to complete in a single iteration, deliver standalone value, and be independently testable.

## What A User Story Is Not

> A user story is not a technical task or implementation detail. "As a developer, I want to create a DB table" is not a user story. Items like "set up an API endpoint," "refactor the auth module," or "add a database index" are technical tasks, not user stories. Slicing work by frontend, backend, and database instead of by vertical user value is an anti-pattern.

## Story Quality Bar

A valid story:
- is written from the user or actor perspective
- delivers a cohesive vertical slice of value
- is small enough to implement independently
- can be reviewed and tested on its own

A bad story:
- is framed from the builder perspective
- exists only to create infrastructure
- bundles unrelated UI, backend, and data work without a single user outcome
- embeds technical design decisions that belong later in the pipeline

## Step 0: Load glossary

Read:
- `./tmp/planning/glossary.md`
- `./tmp/planning/global-architecture.md`

Use the glossary terms consistently. Never introduce an alternative name for an existing concept.

If either shared file is missing, stop and tell the user to run `/a-global-architecture` first.

## Step 1: Resolve inputs

`$ARGUMENTS` = `<epic-slug>`

Read `./tmp/planning/<epic-slug>/idea.md`.

If `idea.md` does not exist, report the exact path checked and stop. Do not fall back to another file or prompt mode.

Also follow references from `idea.md` to supporting materials such as product notes, design files, screenshots, research, or prototype links. Keep a list of what was read.

Output:
```text
Epic slug: <epic-slug>
Epic summary: <one paragraph>
Referenced artifacts: <list or none>
```

## Step 2: Create personas

Derive the actors and usage contexts needed to reason about the epic. Write `./tmp/planning/<epic-slug>/personas.md`.

Use this structure:

```md
# <Epic Name> Personas

> Epic: <epic-slug>
> Generated: <date>

## Persona 1: <name>
- Role: ...
- Primary goals: ...
- Current pain points: ...
- Context of use: ...
- Permissions or constraints: ...

## Persona 2: <name>
...

## Shared Constraints
- ...

## References
- ...
```

Only include personas that matter to the epic. Avoid speculative future roles.

## Step 3: Break the epic into stories

Split the work into minimal, user-facing stories. For each story:
- use canonical format: _As a_ [role], _I want_ [action], _so that_ [benefit]
- include a brief user context
- include numbered acceptance criteria in _Given_ / _When_ / _Then_ form
- include requirements only when they are truly part of the user-facing outcome
- assess prerequisites or dependencies between stories

Before writing files, display each story title and canonical statement.

## Step 4: Classify the stories

Classify each story as:
1. **Actionable** — can be taken into architecture and detailed breakdown now
2. **Blocked** — depends on another story or a prerequisite not yet available
3. **Nice to have** — valid but not essential for the epic's first valuable iteration

Display the classification table before writing outputs.

## Step 5: Write `epic.md`

Write `./tmp/planning/<epic-slug>/epic.md` with this structure:

```md
# <Epic Name> (<epic-slug>)

> Epic: <summary>
> Generated: <date>

## Story 1: <title>

_As a_ [role], _I want_ [action], _so that_ [benefit].

### User Context
- User Role: ...
- User Goals: ...
- Use Case: ...

### Acceptance Criteria
1. [ ] _Given_ ...
       _When_ ...
       _Then_ ...
2. [ ] _Given_ ...
       _When_ ...
       _Then_ ...

### Fields
- Group fields by page, view, or interaction surface
- For each field, note the exact source or rationale

### Requirements
- ...

### UX Considerations
- ...

### Dependencies
- ...

---

## Nice to Have
...

## References
- ...
```

Do not look at the codebase to determine fields. Derive them from the idea and product artifacts only.

## Step 6: Update glossary

If this step reveals durable product terms that later stages must reuse, update `./tmp/planning/glossary.md`.

Rules:
- never remove entries
- never rename an existing term without explicit user approval
- at this stage, `Code Name` and `Source` may be `—` when the codebase has not yet been investigated

## Step 7: Present to user

Summarize:
1. story count by classification
2. recommended starting story
3. personas created
4. assumptions and open questions
5. any glossary entries added

Ask the user to review and approve before moving to `/a-architecture`.

## Success Criteria

- [ ] `epic.md` exists at `./tmp/planning/<epic-slug>/epic.md`
- [ ] `personas.md` exists at `./tmp/planning/<epic-slug>/personas.md`
- [ ] every story uses canonical _As a / I want / so that_ format
- [ ] every story has numbered acceptance criteria in _Given / When / Then_ form
- [ ] stories are sliced by user value, not by tech layer
- [ ] any durable new terms were added to `./tmp/planning/glossary.md`
- [ ] no synonyms were introduced
- [ ] the user reviewed the output before the pipeline advanced

## Error Handling

- **Empty arguments** — ask the user to provide an epic slug
- **Missing `idea.md`** — report the exact path checked and ask the user to create it first
- **Weak input** — say what is missing, keep assumptions explicit, and ask the user instead of inventing certainty
