---
description: Design the technical architecture for an epic from stories, personas, and the codebase
argument-hint: <epic-slug>
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, Skill, AskUserQuestion]
---

# Architecture

Pipeline position:
```text
a-epic -> a-architecture -> a-story(s) -> a-criterion(s)
           ^current
```

### Pipeline I/O

| Direction  | File                                     | Description                                                                                       |
| ---------- | ---------------------------------------- | ------------------------------------------------------------------------------------------------- |
| **In**     | `./planning/<epic-slug>/idea.md`         | Raw epic idea and links to supporting artifacts                                                   |
| **In**     | `./planning/<epic-slug>/epic.md`         | Story list from `/a-epic`                                                                         |
| **In**     | `./planning/<epic-slug>/personas.md`     | Personas from `/a-epic`                                                                           |
| **In/Out** | `./planning/glossary.md`                 | Shared naming baseline from `/a-global-architecture`; update durable confirmed terms and mappings |
| **In/Out** | `./planning/global-architecture.plan.md` | Shared repo map from `/a-global-architecture`; update only with durable cross-epic structure      |
| **Out**    | `./planning/<epic-slug>/architecture.plan.md` | Epic-specific architecture, critique, and change mapping                                     |

## Purpose

Translate product intent into a grounded architecture for this epic.

This command must clearly separate:
- what the epic is trying to build
- what the current system already looks like
- what architecture is recommended for this epic

It is the first epic-specific step that may inspect the codebase.

## Source Of Truth

For product intent and scope, trust sources in this order:
1. `./planning/<epic-slug>/epic.md`
2. `./planning/<epic-slug>/personas.md`
3. UI-facing design artifacts and references preserved by `epic.md`
4. `./planning/<epic-slug>/idea.md`

For implementation reality, trust existing code and established conventions over prototype structure or inferred models.

Use the hierarchy per inconsistency, not as a blanket rule that one file wins for the whole run.

For every inconsistency:
1. isolate the exact claim or assumption in conflict
2. classify what kind of question it is, such as scope, actor intent, interaction detail, terminology, or implementation reality
3. apply the hierarchy only for that question
4. record both the preferred interpretation and the rejected alternative
5. if the hierarchy is not decisive, or if the difference materially changes the architecture recommendation, stop immediately and ask the user about that specific inconsistency before continuing

## Skills

Use these skills when relevant:
- `explore` for targeted multi-area codebase exploration
- `architecture-blueprint-generator` when `global-architecture.plan.md` is stale or too weak to guide targeted exploration
- `ecoologic-code` to validate naming and pattern alignment
- `software-architecture-design` for meaningful tradeoff decisions
- `mermaid-diagrams` for epic class diagrams, sequence diagrams, and optional ERD review artifacts
- `lovable` when input artifacts reference a Lovable prototype

## Rules

- NEVER write or modify application code, create commits, or write files outside `./planning/`
- NEVER start with broad codebase exploration before understanding the epic inputs
- NEVER silently trust a prototype or UI-shaped data model
- NEVER define synonyms; glossary terms stay canonical unless the user explicitly approves a rename
- Treat inferred models as hypotheses until challenged against the codebase and project conventions
- Prefer existing code and established conventions over prototype structure when they conflict
- Update `glossary.md` only for durable confirmed terms or mappings; ask before renaming an existing term
- Update `global-architecture.plan.md` only for durable cross-epic structure, not epic-local design detail

## Step 1: Resolve required inputs

`$ARGUMENTS` = `<epic-slug>`

If `<epic-slug>` is empty or missing, stop and ask the user to provide it. Do not guess or continue with partial context.

Read:
- `./planning/<epic-slug>/idea.md`
- `./planning/<epic-slug>/epic.md`
- `./planning/<epic-slug>/personas.md`
- `./planning/glossary.md`
- `./planning/global-architecture.plan.md`

If `idea.md`, `epic.md`, or `personas.md` is missing, stop and report the exact missing path. The expected producer is `/a-epic`.

If `glossary.md` or `global-architecture.plan.md` is missing, stop and tell the user to run `/a-global-architecture` first.

Also follow references from those files to supporting artifacts such as designs, screenshots, specs, prototype repos, or research notes. Treat each followed reference as required input for this run. If any followed reference cannot be found, accessed, or read, stop and report the exact reference and the file that referenced it. Keep an explicit list of what was read.

Extract:
- epic name and slug
- story list and summaries
- personas and constraints
- domain concepts and obvious relationships
- contradictions, gaps, and unknowns

## Step 2: Understand the target system

Before exploring the codebase, derive from the inputs:
1. intended user flows
2. domain concepts implied by the stories
3. likely entities and relationships
4. likely system areas involved
5. open questions and weak assumptions

### 2a. Infer an ERD from the inputs

Infer a provisional domain model from all useful input evidence, not only the UI.

If evidence is strong enough:
- include the inferred ERD in `architecture.plan.md`
- label it as a review artifact, not accepted truth

If evidence is weak:
- say so explicitly
- record what evidence is missing
- do not fabricate entities or relationships

### 2b. Apply source-of-truth hierarchy

When sources disagree, apply the hierarchy above per inconsistency instead of falling back to `idea.md` or guesswork.

Specifically:
1. `epic.md` beats `personas.md` only for explicit epic scope and story definition
2. `personas.md` sharpens actor intent and context when `epic.md` is less specific
3. preserved UI design artifacts clarify interaction details, but do not silently override epic scope
4. `idea.md` is background context once the epic packet exists
5. existing code and established conventions beat prototype structure for implementation decisions
6. the inferred ERD remains a hypothesis until validated

Do not decide "the conflict is in `epic.md`" or "the conflict is in `idea.md`" as a bulk conclusion. Resolve each differing statement on its own merits.

If a contradiction materially changes the architecture recommendation, stop, surface that exact contradiction immediately, and resolve it with the user before continuing.

## Step 3: Load shared repo context

Read `./planning/global-architecture.plan.md` and use it to narrow exploration.

If it is stale or too weak:
- do targeted structural exploration or invoke `architecture-blueprint-generator`
- refresh `global-architecture.plan.md` only with durable cross-epic structure

Use the shared map to understand:
- major system areas
- responsibilities and boundaries
- communication paths between parts
- stable contracts and integrations

## Step 4: Explore relevant codebase areas

Use targeted exploration only in areas relevant to the stories and still needing confirmation.

Use `Agent` with explore subagents or equivalent targeted search. Launch one agent per relevant area, up to 5, and reserve one slot for a prototype source when present.

Each exploration prompt must include:
1. the story list
2. the inferred entities, flows, and open questions
3. the glossary baseline
4. the specific system area to inspect

Each exploration result must report:
- relevant file paths
- existing patterns and conventions
- reuse candidates
- naming matches and conflicts
- how the area communicates with the rest of the system
- any durable structure that may belong in `global-architecture.plan.md`

Display a summary of findings by system area before moving on.

## Step 5: Reconcile terminology

Build a terminology table for `architecture.plan.md`:

| Domain Term | Code Name | Definition | Source | Status |
| ----------- | --------- | ---------- | ------ | ------ |

Status values:
- `exists`
- `new`
- `exists (extend with ...)`
- `conflict`
- `rename-request`

Rules:
- existing glossary terms remain canonical unless the user approves a change
- add safe new glossary rows and safe enrichments to `glossary.md` in this command
- do not silently rename existing glossary terms
- keep conflicts and rename requests explicit in `architecture.plan.md` and review them with the user before writing outputs

## Step 6: Make architecture decisions

Organize decisions around change types:

| Area | What Exists | What Changes | Decision | Rationale |
| ---- | ----------- | ------------ | -------- | --------- |

Action types:
- **Reuse as-is**
- **Extend**
- **Extract**
- **New**

Ground decisions in:
1. epic inputs and intended flows
2. current system structure
3. project conventions already present in the codebase

If a decision has meaningful tradeoffs, present options with pros and cons and resolve them with the user before writing outputs.

### 6a. Review open questions before writing

Before writing `architecture.plan.md` or updating shared artifacts, present the current architecture direction to the user.

Include:
- input conflicts and gaps, listed one by one
- terminology conflicts and rename requests
- decisions with meaningful tradeoffs
- any weak assumptions that affect the recommended model

For each conflict or tradeoff, present explicit options, state which option the hierarchy or codebase evidence favors, and explain the downstream impact.

Persist every resolved source-of-truth inconsistency in `architecture.plan.md` under the same section structure described below so later stages inherit the decision history instead of re-opening the same conflict.

Pause for user feedback on these items before continuing to the write steps.

## Step 7: Critique the inferred model

The architecture document must contain:

### 7a. Inferred ERD from inputs

Include it when evidence is strong enough.

### 7b. Architectural critique of the inferred ERD

Critique it harshly. Evaluate:
1. entity and aggregate boundaries
2. ownership and lifecycle boundaries
3. relationship quality and direction
4. naming and glossary alignment
5. consistency with existing code and conventions
6. suspicious UI-shaped or convenience-driven entities
7. status blobs, nullable-field sprawl, duplicated data, and missing invariants
8. missing tenant, auth, or access boundaries

Say clearly:
- what to keep
- what to rename
- what to split or merge
- what to remove
- what remains uncertain

### 7c. Recommended domain model

After critique and codebase comparison, propose the model that should guide this epic.

Represent the recommended model in an epic class diagram focused on the entities, components, boundaries, and relationships that must be added, extended, extracted, or reused for this epic.

### 7d. Epic sequence diagrams for required changes

Rules:
- these are required deliverables, separate from the optional inferred ERD
- cover the whole epic through its major user and system interactions
- include more than one sequence diagram when a single flow cannot represent the epic clearly
- map each sequence diagram back to the relevant stories
- show the main actors, system boundaries, and handoffs introduced or affected by the epic

### 7f. Change inventory

List every new or modified artifact that later story and criterion work will depend on.

## Step 8: Write `architecture.plan.md`

Write `./planning/<epic-slug>/architecture.plan.md` with this structure:

```md
# <Epic Name> — Architecture
> Epic: <epic-slug>
> Generated: <date>
> Stories: `./planning/<epic-slug>/epic.md`
> Personas: `./planning/<epic-slug>/personas.md`

## Epic Summary
## Resolved Source-of-Truth Decisions
- Use this section only for inconsistencies that were actually resolved during this step
- Record each resolved inconsistency as its own item using this shape:
  - Question: ...
  - Option A: ...
  - Option B: ...
  - Chosen: ...
  - Basis: which source or evidence won for this specific question, and why
  - Impact: how the decision changed architecture, terminology, reuse, or boundaries
- If no inconsistencies were resolved, write `- None`

### Remaining Input Conflicts and Gaps

List only the contradictions, missing inputs, and weak assumptions that still remain after discussion with the user. Record them as individual items, not bulk file-level conflict notes. This section records items explicitly left open by user choice or still awaiting later resolution.

## Terminology
| Domain Term | Code Name | Definition | Source | Status |

### Key Domain Concepts

## Current System Landscape

### <system area>
### Communication Paths and Boundaries

## Reuse and Extraction Plan
| Candidate | Source | Action | Stories | Target System Area |

## Technical Decisions
| Area | What Exists | What Changes | Decision | Rationale |

## Diagrams and Model Review

### Recommended Epic Class Diagram
### Recommended Epic Sequence Diagrams

## Change Inventory
| Type | Name | Action | Story | Details |

## Story Mapping
| Story | System Areas | New | Modified | Reused | Risk |

## Upstream Updates Applied
- glossary updates made in this run
- global architecture updates made in this run
- conflicts or rename requests left for user review

## Risks and Open Questions
## References
```

## Step 9: Update shared artifacts

### 9a. Update glossary

Update `./planning/glossary.md` in this command when the findings are durable and safe:
- add new terms
- enrich existing rows with confirmed code names, sources, or statuses

Do not:
- remove rows
- rename an existing term without explicit user approval
- persist uncertain conflicts as canonical truth

### 9b. Update global architecture

Update `./planning/global-architecture.plan.md` only with durable cross-epic structure such as:
- stable modules and boundaries
- major responsibilities
- communication paths
- stable contracts and integrations

Do not merge back:
- current epic goals
- story-specific rationale
- temporary assumptions
- epic-local design detail

## Step 10: Present to user

Summarize:
- key decisions
- ERD critique and recommended model
- reuse opportunities
- glossary updates applied
- glossary conflicts or rename requests still open
- global architecture updates applied
- risks and open questions

Invite final feedback or corrections before moving to `/a-story`. Do not use this step as the primary discussion gate for conflicts or tradeoffs.

## Success Criteria

- [ ] `architecture.plan.md` exists with the required sections
- [ ] all required inputs and followed references were validated before architecture work continued
- [ ] every story appears in Story Mapping and Change Inventory
- [ ] the inferred ERD is included or explicitly unavailable
- [ ] the inferred ERD is criticized, not just described
- [ ] the recommended domain model is explicit
- [ ] the epic-wide class diagram is included
- [ ] the epic-wide sequence diagrams are included
- [ ] resolved inconsistencies, if any, were persisted in `architecture.plan.md` under `## Resolved Source-of-Truth Decisions`, or `- None` was written explicitly
- [ ] any safe durable glossary updates were applied
- [ ] any `global-architecture.plan.md` updates are lean and cross-epic
- [ ] blocking conflicts, tradeoffs, and weak assumptions were reviewed with the user before files were written

## Error Handling

- **Empty arguments** — ask the user to provide `<epic-slug>` and stop
- **Missing `epic.md` or `personas.md`** — report the path checked and tell the user to run `/a-epic`
- **Missing `idea.md`** — report the path checked and tell the user to run `/a-epic`
- **Missing `glossary.md` or `global-architecture.plan.md`** — stop and tell the user to run `/a-global-architecture`
- **Missing or unreadable followed reference** — report the exact reference and originating file and stop instead of skipping it
- **Weak `global-architecture.plan.md`** — continue, perform targeted structural mapping, and keep the shared file lean
- **Empty or new codebase** — say so explicitly and focus on greenfield decisions
- **Inputs too weak for an ERD** — record the gap instead of fabricating certainty
- **Conflicting input artifacts** — surface the conflict immediately and pause for user direction before continuing
