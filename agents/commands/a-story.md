---
description: Break down a user story into implementation tasks with code investigation, UX review, and consistency checks
argument-hint: <epic-slug> <story-number>
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, TaskCreate, TaskUpdate, TaskList, AskUserQuestion, Skill]
---

# Story Breakdown

This command is a single step of a longer pipeline:
```
a-epic -> a-personas -> a-architecture -> a-story(s) -> a-task(s-t)
                                           ^current
```
Next: `/a-task` consumes the task files produced by this command

### Pipeline I/O

| Direction | File | Description |
|-----------|------|-------------|
| **In**  | `./tmp/planning/<epic-slug>/epic.md`          | User stories from `/a-epic` |
| **In**  | `./tmp/planning/<epic-slug>/architecture.md`  | Architecture from `/a-architecture` |
| **In**  | `./tmp/planning/<epic-slug>/personas.md`       | Personas (optional) |
| **In/Out** | `./tmp/planning/glossary.md`                    | Shared glossary (read for consistent naming, updated with new terms) |
| **In/Out** | `./tmp/planning/global-architecture.md`         | Global architecture map (read for context, updated with new findings) |
| **Out** | `./tmp/planning/<epic-slug>/story-<N>/details.md`  | Story details document |
| **Out** | `./tmp/planning/<epic-slug>/story-<N>/task-<N>.md` | Individual task files |
| **Out** | `./tmp/planning/<epic-slug>/architecture.md`       | Addendum (if new insights found) |

## Skills

Invoke these skills during execution via Skill tool when conditions are met:
- `ux-laws` — UX evaluation (Step 4), always invoke for stories with UI
- `react-best-practices` — component design validation (Step 5), invoke if project uses React
- `typescript-best-practices` — type design validation (Step 5), invoke if project uses TypeScript
- `web-design-guidelines` — UI compliance check (Step 5), invoke if story involves web UI

## Purpose

Break a single user story (from `/a-epic` output) into concrete implementation tasks. Investigate the codebase, check consistency, identify reuse opportunities, and define UX/UI before producing the task list.

**IMPORTANT**: This command produces a task breakdown document. It does NOT write implementation code. Code is written in the task step. However, codebase read access is allowed and expected.

## Rules

- NEVER write or modify application code, create commits, or write files outside `./tmp/planning/`
- NEVER define synonyms — if a term exists in the glossary, use its exact Code Name everywhere. One concept = one name
- NEVER abbreviate new names — use the domain's exact terms (`team-management`, not `team-mgmt`; `UserProfile`, not `UsrProf`)
- NEVER propose extractions for hypothetical future use (YAGNI)
- NEVER start implementation after generating planning artifacts

## Anti-Patterns

- NEVER skip codebase exploration — tasks must be grounded in existing patterns
- NEVER create tasks that address multiple concerns — one concern per task

## Step 1: Resolve story input

`$ARGUMENTS` = `<epic-slug> <story-number>`

Parse the two values:
- **epic-slug** — used to resolve paths under `./tmp/planning/<epic-slug>/`
- **story number** — which story to break down (e.g. `2` for "Story 2")

Read `./tmp/planning/<epic-slug>/epic.md` via Read tool. Extract the specified story section (everything under `## Story N: ...` until the next `## Story` or end of file). This is the **story context** for all subsequent steps.

Also read `./tmp/planning/<epic-slug>/architecture.md` via Read tool for technical context.

Read `./tmp/planning/glossary.md` if it exists. Use its terms and Code Names consistently throughout all outputs. Never introduce alternative names for glossary terms.

Check if `./tmp/planning/<epic-slug>/personas.md` exists. If yes, read it. If no, note its absence but continue — personas are optional input.

Define these terms for consistent use throughout:
- **Story context**: the full extracted story section (title, "As a..." statement, acceptance criteria, fields, requirements, UX considerations)
- **Story summary**: the story title + "As a..." statement (one-liner for agent prompts)

Output:
```
Story: <story title>
Epic: <epic name from file header>
Architecture: loaded
Personas: <loaded | not found — proceeding without>
Has UI: <yes | no>
```

## Step 2: Codebase investigation

Read `./tmp/planning/global-architecture.md` if it exists. Use it as baseline context for exploration — focus agents on areas not covered or potentially outdated.

Use the Agent tool with `subagent_type="Explore"` to investigate the codebase in parallel. Launch up to 3 explore agents simultaneously for:

### 2a. Find related existing code

Prompt: "Find all files, components, services, models, routes, and tests related to: [story summary]. Look for existing implementations that overlap, adjacent features, and shared utilities. Report file paths, key exports, and brief descriptions."

### 2b. Find patterns and conventions

Prompt: "Identify the project's patterns for: routing, state management, API calls, form handling, validation, component structure, styling approach, test structure. Focus on patterns relevant to: [story summary]. Report the conventions with file examples."

### 2c. Find reuse opportunities

Prompt: "Search for existing components, hooks, utilities, services, types, and abstractions that could be reused or extended for: [story summary]. Also identify near-duplicates that should be extracted into shared code. Report each with file path and rationale."

Collect results from all three agents and structure findings as:

**Related Files**

| File | Type | Relevance |
|------|------|-----------|
| `src/...` | component/service/model/... | Brief description of how it relates |

**Conventions**
- Routing: [pattern with file example]
- State management: [pattern with file example]
- API calls: [pattern with file example]
- ... (only conventions relevant to this story)

**Reuse Candidates**

| Candidate | File | Action |
|-----------|------|--------|
| ... | `src/...` | Reuse as-is / Extend / Extract from |

## Step 3: Consistency check

Based on Step 2 findings, evaluate (analysis only — do not create or modify files):

1. **Naming conventions** — Do existing entities follow a naming pattern? What should new entities be named?
2. **File structure** — Where should new files go based on existing layout?
3. **API patterns** — How do existing endpoints/services work? What shape should new ones follow?
4. **Component patterns** — What component structure, prop patterns, and composition strategies are used?
5. **Test patterns** — How are similar features tested? What test utilities exist?
6. **Type patterns** — How are types/interfaces organized? Shared types file? Co-located?

Flag any inconsistencies found in the existing code that should be noted (but NOT fixed as part of this story unless directly related).

Output: Display key consistency findings and any flags before proceeding.

## Step 4: UX definition

> If the story has no UI, skip Steps 4-5 and note "No UI — Steps 4-5 skipped" in the output.

Invoke the `ux-laws` skill via Skill tool to evaluate the story's user experience:

1. Review the story's acceptance criteria and user context
2. Apply relevant UX laws (Hick's, Fitts's, Miller's, Jakob's, etc.)
3. Define:
   - **User flow** — step-by-step interaction from the user's perspective
   - **States** — empty, loading, loaded, error, edge cases
   - **Feedback** — what the user sees/hears at each step
   - **Accessibility** — keyboard nav, screen readers, focus management

If the story has a UI design reference (linked in the stories file), read it and cross-reference with UX laws. Flag any design inconsistencies.

Output: Display the user flow and states table before proceeding.

## Step 5: UI definition

Based on existing codebase patterns (Step 2b) and UX definition (Step 4):

1. **Component inventory** — List every UI component needed (new and existing)
2. **Component hierarchy** — Parent/child relationships
3. **Props and state** — Key props, local state, shared state for each component
4. **Styling approach** — Follow the project's existing styling method
5. **Responsive behavior** — Mobile/desktop differences if applicable

If the project uses React, invoke the `react-best-practices` skill via Skill tool to validate component design decisions.

If the project uses TypeScript, invoke the `typescript-best-practices` skill via Skill tool to validate type design.

If the story involves web UI, invoke the `web-design-guidelines` skill via Skill tool to cross-check.

Output: Display the component inventory table and hierarchy before proceeding.

## Step 6: Identify extraction opportunities

From Steps 2-5, list any code that should be extracted or refactored:

1. **New shared components** — UI pieces usable beyond this story
2. **New shared utilities** — Logic usable beyond this story
3. **New shared types** — Types usable beyond this story
4. **Refactors** — Existing code that should be cleaned up to support this story

For each, state:
- What to extract
- From where (existing file) or why (new need)
- Where it should live
- Whether it blocks the story or can be done in parallel

**IMPORTANT**: Only propose extractions that are clearly justified. Follow YAGNI — do not extract for hypothetical future use.

Output: Display the extractions table before proceeding.

## Step 7: Define implementation tasks

Break the story into ordered, atomic implementation tasks. Each task should be:
- **Small** — completable in a single focused session
- **Testable** — has clear verification criteria
- **Independent** — can be committed and (ideally) deployed separately
- **Ordered** — dependencies are explicit

For each task, write via Write tool to `./tmp/planning/<epic-slug>/story-<N>/task-<T>.md`:

```markdown
### Task T: <imperative title>

**Type**: [component | hook | service | api | model | migration | test | config | refactor]
**Files**: [list of files to create or modify]
**Depends on**: [Task numbers, or "none"]

**Description**:
[What to implement, with specifics from the codebase investigation]

**Acceptance criteria**:
- [ ] [Specific, testable criterion]
- [ ] [Another criterion]

**Notes**:
- [Relevant findings from codebase investigation]
- [Patterns to follow, with file references]
- [Reuse opportunities identified]
```

Example task:

```markdown
### Task 1: Add UserProfile model and migration

**Type**: model | migration
**Files**: src/models/UserProfile.ts, src/migrations/20240101_add_user_profile.ts
**Depends on**: none

**Description**:
Create the UserProfile entity following the existing model pattern in `src/models/User.ts`. Add a migration for the `user_profiles` table with fields from the story's Fields section.

**Acceptance criteria**:
- [ ] UserProfile model exists with all required fields
- [ ] Migration creates the user_profiles table
- [ ] Model follows the naming and structure conventions from existing models

**Notes**:
- Follow the BaseEntity pattern from `src/models/Base.ts`
- Use the same column decorator style as `src/models/User.ts`
```

### Task ordering guidelines

1. Types/interfaces first (if new shared types are needed)
2. Data layer (models, migrations, API routes)
3. Business logic (services, hooks)
4. UI components (bottom-up: leaf components first, then containers)
5. Integration (wiring components together, routing)
6. Tests (or alongside each task if TDD is preferred)

## Step 8: Update glossary

If codebase investigation (Step 2) revealed new domain terms, or if terms gained Code Names or Sources that were previously `—`, add them to `./tmp/planning/glossary.md`. Create the file if it doesn't exist. Never remove existing entries. Never rename existing terms — ask the user if there's a conflict.

## Step 9: Write the story details

Write the story details via Write tool to `./tmp/planning/<epic-slug>/story-<N>/details.md`.

Create the directories if they don't exist (`mkdir -p`).

If findings during investigation revealed new architectural insights, append them to `./tmp/planning/<epic-slug>/architecture.md` under a new section `## Addendum from Story <N>`.

If codebase investigation revealed new endpoints, packages, stores, or structural changes not in `./tmp/planning/global-architecture.md`, update it inline in the relevant section.

### details.md structure

```markdown
# <Story Title> — Details

> Story: <full story statement>
> Epic: <epic name>
> Generated: <date>
> Personas: <loaded | N/A>

## Codebase Context

### Related Code
- [Summary of findings from Step 2a]

### Patterns to Follow
- [Summary of findings from Step 2b]

### Reuse Opportunities
- [Summary of findings from Step 2c]

## Consistency Notes
- [Key findings from Step 3]

## UX Definition

### User Flow
1. [Step-by-step flow]

### States
| State | Description | UI Behavior |
|-------|-------------|-------------|
| ... | ... | ... |

### Accessibility
- [Key a11y requirements]

## UI Definition

### Component Inventory
| Component | New/Existing | Location |
|-----------|-------------|----------|
| ... | ... | ... |

### Component Hierarchy
- [Parent/child tree]

## Extractions
| What | From/Why | Target Location | Blocks Story? |
|------|----------|-----------------|---------------|
| ... | ... | ... | ... |

## Tasks

- Task 1: <title> -> `task-1.md`
- Task 2: <title> -> `task-2.md`
- ...

---

## References
- Epic: `./tmp/planning/<epic-slug>/epic.md`
- Architecture: `./tmp/planning/<epic-slug>/architecture.md`
- [Any design docs, API docs, or other references from the story]
```

## Step 10: Present to user

Summarize:
1. Number of tasks identified
2. Estimated dependency chain (critical path)
3. Any risks or open questions
4. Suggested starting task

Ask the user to review before proceeding to implementation.

Implementation happens in `/a-task`.

## Success Criteria

- [ ] `details.md` exists at `./tmp/planning/<epic-slug>/story-<N>/details.md`
- [ ] All task files exist at `./tmp/planning/<epic-slug>/story-<N>/task-<T>.md`
- [ ] Every task has: Type, Files, Depends on, Description, Acceptance criteria
- [ ] Task dependencies form a valid DAG (no cycles)
- [ ] `glossary.md` at `./tmp/planning/glossary.md` is updated with any new terms discovered
- [ ] No synonyms — every concept uses its glossary Code Name consistently
- [ ] User has been presented a summary and reviewed

## Error Handling

- **Empty arguments** — Ask the user to provide both epic slug and story number
- **`epic.md` does not exist** — Report path checked (`./tmp/planning/<epic-slug>/epic.md`), tell user: "Run `/a-epic` first."
- **Story N not found in epic.md** — List available story numbers from the file, ask the user to pick one
- **`architecture.md` does not exist** — Report path checked (`./tmp/planning/<epic-slug>/architecture.md`), tell user: "Run `/a-architecture` first."
- **Codebase exploration returns no results** — Report to user, ask if this is a new feature area, skip consistency checks, focus on patterns from elsewhere in the codebase
