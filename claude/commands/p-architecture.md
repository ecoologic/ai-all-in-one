---
description: Design the technical architecture for an epic based on stories and personas
argument-hint: <stories-file-path>
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, Skill, AskUserQuestion]
---

# Architecture

Pipeline:
```
p-epic -> p-personas -> [p-architecture] -> p-story(N) -> p-task(N×M) -> p-review -> p-review-*(K) -> p-review-issue(K) -> p-pr -> p-pr-comments(C)
                         ^current
```

## Skills

Invoke these skills during execution:
- `explore` — codebase exploration (Step 2)
- `ecoologic-code` — domain modeling, vertical slices, ubiquitous language (Steps 3-4)
- `mermaid-diagrams` — all architecture diagrams (Step 5)

## Purpose

Produce a technical architecture document for an epic. This bridges user stories (what) and implementation tasks (how) by defining the system design, domain model, and key technical decisions.

**This command produces documentation only. No code. No commits.**

## Step 1: Resolve input

### 1a. Resolve docs path

1. Run `basename $(git rev-parse --show-toplevel)` to get the git root folder name
2. If `~/dev/docs/settings.json` exists and has a key matching that name under `projects`:
   - Use `name` as `<project>` if present, otherwise keep the git root basename
   - Use `epic` as the default `<epic-slug>` when no argument is provided
3. Docs root: `~/dev/docs/<project>/`

### 1b. Find the epic

Parse `$ARGUMENTS` for either:
- A full path to `stories.md` (e.g. `~/dev/docs/pineapple/user-auth/stories.md`)
- Just the slug (e.g. `user-auth`) → resolves to `~/dev/docs/<project>/user-auth/stories.md`

If missing:
- Check `~/dev/docs/settings.json` for a default `epic` under the current project — if found, use it
- Otherwise search for `~/dev/docs/<project>/*/stories.md` files
  - If exactly one exists, use it (confirm with user)
  - If multiple exist, list them and ask user to pick
- If none exist, tell user: "Run `/p-epic` first to generate stories."

### 1c. Extract context

Read the stories file. Extract:
- Epic name (from the file header)
- `<epic-slug>` — inferred from the folder name (e.g. `~/dev/docs/pineapple/user-auth/` → `user-auth`)
- All story summaries (title + "As a..." statement)

Check if `~/dev/docs/<project>/<epic-slug>/personas.md` exists. If yes, read it. If no, note its absence but continue — personas are optional input.

Output:
```
Project: <project>
Epic: <name> (<epic-slug>)
Docs: ~/dev/docs/<project>/<epic-slug>/
Stories: <count>
Personas: <loaded | not found — proceeding without>
```

## Step 2: Explore current codebase

Use the Agent tool with `subagent_type="Explore"` to investigate the existing system. Launch up to 3 explore agents **in parallel**:

### 2a. Existing architecture

Prompt: "Map the high-level architecture: entry points, layers, module boundaries, data flow, external dependencies. Report as a structured summary with file paths."

### 2b. Domain model

Prompt: "Find all domain entities, value objects, aggregates, enums, and their relationships. Look at models, types, schemas, database migrations. Report entity names, key fields, and relationships."

### 2c. Infrastructure and integrations

Prompt: "Identify infrastructure: databases, queues, caches, external APIs, auth providers, file storage, CI/CD. Report each with its configuration location and usage patterns."

Collect and summarize results.

## Step 3: Domain analysis

Apply `ecoologic-code` skill principles:

1. **Ubiquitous language** — Extract domain terms from stories and personas. Map to existing codebase terms. Flag mismatches.
2. **Bounded contexts** — Identify which bounded contexts the epic touches. Are new ones needed?
3. **Aggregates** — Define aggregate roots and boundaries. Keep aggregates small.
4. **Domain events** — What events does the epic introduce? Who produces/consumes them?

Output a domain glossary table:

| Term | Definition | Existing Code Term | Status                  |
| ---- | ---------- | ------------------ | ----------------------- |
| ...  | ...        | ...                | new / existing / rename |

## Step 4: Technical decisions

For each significant technical choice, present:

| Decision | Options | Choice | Rationale |
| -------- | ------- | ------ | --------- |
| ...      | A, B, C | B      | ...       |

Cover at minimum:
1. **Data model changes** — new tables/collections, migrations needed
2. **API design** — new endpoints, modifications to existing
3. **State management** — where state lives, how it flows
4. **Authentication/authorization** — new permissions, roles
5. **Error handling** — failure modes, recovery strategies

If a decision has significant tradeoffs, present options with pros/cons and **ask the user** via `AskUserQuestion` before committing.

## Step 5: Architecture diagrams

Invoke the `mermaid-diagrams` skill. Generate only the diagrams relevant to the epic:

### 5a. C4 Context diagram

Show the system in its environment: users, external systems, the system boundary.

### 5b. C4 Container diagram

Show major containers (apps, services, databases) and their interactions.

### 5c. Domain model diagram

Class diagram showing entities, value objects, aggregates, and relationships.

### 5d. Sequence diagram(s)

One per key user flow from the stories. Show the interaction between components.

**Skip any diagram that adds no value for this specific epic.**

## Step 6: Story-architecture mapping

Map each story to the architectural components it touches:

| Story        | Components        | New         | Modified | Risk |
| ------------ | ----------------- | ----------- | -------- | ---- |
| Story 1: ... | Auth, UserProfile | UserProfile | Auth     | low  |
| Story 2: ... | ...               | ...         | ...      | ...  |

Risk levels: `low` (isolated change), `medium` (crosses boundaries), `high` (core infrastructure change).

## Step 7: Write architecture document

Write to `~/dev/docs/<project>/<epic-slug>/architecture.md` with this structure:

- `# <Epic Name> — Architecture` — with blockquote metadata (Epic, Generated date, Stories path, Personas path or "N/A")
- `## Current System` — subsections: Overview (from Step 2a), Relevant Infrastructure (from Step 2c)
- `## Domain Model` — subsections: Glossary table (from Step 3), Bounded Contexts, Domain Events
- `## Technical Decisions` — table from Step 4
- `## Diagrams` — subsections each with a mermaid code block: System Context (C4), Containers (C4), Domain Model (class diagram), Key Flows (sequence diagrams)
- `## Story Mapping` — table from Step 6
- `## Risks and Open Questions` — bulleted list
- `## References` — links to stories and personas files

## Step 8: Present to user

Summarize:
1. Key architectural decisions made
2. New components/services introduced
3. Risks identified
4. Open questions needing answers

Ask the user to review before proceeding to `/p-story`.

**No code is written by this command.**

## Error handling

- **Missing stories file** → tell user: "Run `/p-epic` first to generate stories."
- **Empty/new codebase** → skip Step 2, focus on greenfield architecture decisions. Note this in the document.
- **Stories reference unknown domain concepts** → flag and ask user for clarification via `AskUserQuestion`
- **Personas file not found** → proceed without. Note absence in the output document.
