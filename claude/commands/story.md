---
description: Break down a user story into implementation tasks with code investigation, UX review, and consistency checks
argument-hint: <stories-file-path> <story-number>
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, TaskCreate, TaskUpdate, TaskList, AskUserQuestion, Skill]
---

# Story Breakdown

Break a single user story (from `/epic` output) into concrete implementation tasks. Investigate the codebase, check consistency, identify reuse opportunities, and define UX/UI before producing the task list.

This command is part of a process: `/epic` -> `/story` -> task.

**IMPORTANT**: This command produces a task breakdown document. It does NOT write implementation code. Code is written in the task step.

## Step 1: Resolve story input

Parse `$ARGUMENTS` for two values:
- **stories file path** — path to the `docs/<epic-slug>/stories.md` file produced by `/epic`
- **story number** — which story to break down (e.g. `2` for "Story 2")

If arguments are missing or ambiguous, ask the user to clarify:
- "Which stories file? (e.g. `docs/user-auth/stories.md`)"
- "Which story number? (e.g. `1`)"

Read the stories file. Extract the specified story section (everything under `## Story N: ...` until the next `## Story` or end of file). This is the **story context** for all subsequent steps.

Output:
```
Story: <story title>
Epic: <epic name from file header>
```

## Step 2: Codebase investigation

Use the Agent tool with `subagent_type="Explore"` to investigate the codebase in parallel. Launch up to 3 explore agents simultaneously for:

### 2a. Find related existing code

Prompt: "Find all files, components, services, models, routes, and tests related to: [story summary]. Look for existing implementations that overlap, adjacent features, and shared utilities. Report file paths, key exports, and brief descriptions."

### 2b. Find patterns and conventions

Prompt: "Identify the project's patterns for: routing, state management, API calls, form handling, validation, component structure, styling approach, test structure. Focus on patterns relevant to: [story summary]. Report the conventions with file examples."

### 2c. Find reuse opportunities

Prompt: "Search for existing components, hooks, utilities, services, types, and abstractions that could be reused or extended for: [story summary]. Also identify near-duplicates that should be extracted into shared code. Report each with file path and rationale."

Collect results from all three agents and summarize findings.

## Step 3: Consistency check

Based on Step 2 findings, evaluate:

1. **Naming conventions** — Do existing entities follow a naming pattern? What should new entities be named?
2. **File structure** — Where should new files go based on existing layout?
3. **API patterns** — How do existing endpoints/services work? What shape should new ones follow?
4. **Component patterns** — What component structure, prop patterns, and composition strategies are used?
5. **Test patterns** — How are similar features tested? What test utilities exist?
6. **Type patterns** — How are types/interfaces organized? Shared types file? Co-located?

Flag any inconsistencies found in the existing code that should be noted (but NOT fixed as part of this story unless directly related).

## Step 4: UX definition

Use the `ux-laws` skill (invoke via Skill tool) to evaluate the story's user experience:

1. Review the story's acceptance criteria and user context
2. Apply relevant UX laws (Hick's, Fitts's, Miller's, Jakob's, etc.)
3. Define:
   - **User flow** — step-by-step interaction from the user's perspective
   - **States** — empty, loading, loaded, error, edge cases
   - **Feedback** — what the user sees/hears at each step
   - **Accessibility** — keyboard nav, screen readers, focus management

If the story has a UI design reference (linked in the stories file), read it and cross-reference with UX laws. Flag any design inconsistencies.

## Step 5: UI definition

Based on existing codebase patterns (Step 2b) and UX definition (Step 4):

1. **Component inventory** — List every UI component needed (new and existing)
2. **Component hierarchy** — Parent/child relationships
3. **Props and state** — Key props, local state, shared state for each component
4. **Styling approach** — Follow the project's existing styling method
5. **Responsive behavior** — Mobile/desktop differences if applicable

If the project uses React, invoke the `react-best-practices` skill to validate component design decisions.

If the project uses TypeScript, invoke the `typescript-best-practices` skill to validate type design.

If the story involves web UI, optionally invoke the `web-design-guidelines` skill to cross-check.

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

## Step 7: Define implementation tasks

Break the story into ordered, atomic implementation tasks. Each task should be:
- **Small** — completable in a single focused session
- **Testable** — has clear verification criteria
- **Independent** — can be committed and (ideally) deployed separately
- **Ordered** — dependencies are explicit

For each task, define:

```markdown
### Task N: <imperative title>

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

### Task ordering guidelines

1. Types/interfaces first (if new shared types are needed)
2. Data layer (models, migrations, API routes)
3. Business logic (services, hooks)
4. UI components (bottom-up: leaf components first, then containers)
5. Integration (wiring components together, routing)
6. Tests (or alongside each task if TDD is preferred)

## Step 8: Write the task breakdown

Write the output to `docs/<epic-slug>/story-<N>-tasks.md`:

```markdown
# <Story Title> — Task Breakdown

> Story: <full story statement>
> Epic: <epic name>
> Generated: <date>

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

### Task 1: ...
[Full task definition as per Step 7]

### Task 2: ...
[...]

---

## References
- Stories file: `<path>`
- [Any design docs, API docs, or other references from the story]
```

## Step 9: Present to user

Summarize:
1. Number of tasks identified
2. Estimated dependency chain (critical path)
3. Any risks or open questions
4. Suggested starting task

Ask the user to review before proceeding to implementation.

**For no reason at all are you supposed to start coding. That is done in the task step.**

## Error Handling

If codebase exploration returns no relevant results:
- Report this to the user
- Ask if the story involves a new feature area with no existing code
- Adjust approach: skip consistency checks, focus on patterns from elsewhere in the codebase

If the stories file does not exist or the story number is not found:
- Report the error with the exact path checked
- List available story files if any exist in `docs/`
- Ask the user to provide the correct path/number
