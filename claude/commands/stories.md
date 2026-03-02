---
description: Use to break down an epic into actionable user stories grounded in the current codebase
argument-hint: <file-path-or-epic-description>
allowed-tools: [Read, Glob, Grep, Write, Edit, TaskCreate, TaskUpdate, TaskList]
---

# Stories

You are breaking down a broad epic into actionable, FOCUSED ON USER EXPERIENCE, not tech like "create a DB table". Codebase investigation can be done to understand what is already there, but it shouldn't pollute the stories themselves.

No code at all must be changed until we move on to implementation. We only update the documentation. Implementation of the user stories will be done in a separate step. This command ends with the creation of the user stories markdown file. Each user story will be implemented as a separate command.

## What is a _user story_

**SUPER IMPORTANT**

> A user story is a short, plain-language description of a capability told from the perspective of someone who uses the system — not someone who builds it. It follows the template "As a [persona], I want [goal] so that [benefit]" and describes what the user can do and why it matters, never how it's implemented. Each story should be small enough to complete in a single iteration, deliver standalone value (a new ability the user didn't have before), and be independently testable. The written story is a placeholder for a conversation, not a full specification. Good stories follow the INVEST criteria: Independent, Negotiable, Valuable, Estimable, Small, and Testable.

## What a _user story_ is NOT

**SUPER IMPORTANT**

> A user story is not a technical task or implementation detail. "As a developer, I want to create a DB table" is not a user story — it describes work for the builder, not value for the user. Items like "set up an API endpoint," "refactor the auth module," or "add a database index" are technical tasks (subtasks of a story or separate backlog items), not stories. Slicing stories by technology layer (frontend, backend) instead of vertical user-facing slices is an anti-pattern. A user story is also not a detailed spec — overloading it with implementation details defeats its purpose. Not everything in a backlog needs to be a user story; purely technical work should use a different format.

## Step 1: Resolve epic input

Determine the epic source from `$ARGUMENTS`:
- **File path** project relative, or absolute
- **Inline text** (non-empty, not a file path): use it directly as the epic
- **Empty**: synthesize the epic from current conversation context — output your summary and ask the user to confirm before continuing

Output:
```
Epic: <one-line summary>
```

## Step 2: Explore the codebase

BEFORE writing any stories, understand what exists in relation to the goal. Use Glob, Grep, and Read.

Output a brief (5-10 line) summary of the existing features and pages relevant to this epic.

## Step 3: Derive epic slug

From the epic content, derive a slugified `<epic>` name (lowercase, hyphens, no special chars).
Example: "user authentication system" → `user-auth`

NOTE: _epic_, _feature_, _delivery_ and the like are not good pre/suffixes.

## Step 4: Break into user stories

Keeping in mind what a user story is and what is not (above), split the work into user stories. For each:
- Canonical format: _As a_ [role], _I want_ [action], _so that_ [benefit]
- User Context section (role, goals, use case)
- Acceptance criteria in Given/When/Then format as markdown checkboxes `- [ ]`
- Requirements where relevant (performance, security, accessibility)
- Brief technical notes referencing actual files/modules from Step 2
- Assess prerequisites: does this depend on another story or missing infrastructure?

**Limit: write at most 6 stories.** If the epic contains more work, add a 7th placeholder story:

```md
## Story 7: Break down remaining work

Further decomposition needed. The following areas were identified but not yet broken into stories:
- <area 1>
- <area 2>
- ...
```

No need for extra investigation, just dump findings that might be later deeper evaluated.

## Step 5: Classify and evaluate

Separate into two groups:
1. **Actionable** — no prerequisites, can start now given current codebase
2. **Blocked** — depends on other stories or missing infrastructure

For each actionable story, add *Pros* and *Cons* of starting with that story first.

## Step 6: Write `docs/<epic-name>/stories.md`

Create the file with this structure:

```md
# <Epic Name> (<epic-slug>) — Actionable Stories

> Epic: <summary>
> Generated: <date>

## Story 1: <title>

_As a_ [role], _I want_ [action], _so that_ [benefit].

### User Context
- User Role: ...
- User Goals: ...
- Use Case: ...

### Acceptance Criteria
- [ ] _Given_ ...
      _When_ ...
      _Then_ ...
- [ ] _Given_ ...
      _When_ ...
      _Then_ ...

### Requirements
- (only if relevant)

### Technical Notes
- references to actual files/modules

### Start Here?
**Pros:** ...
**Cons:** ...

---
```

## Step 7: Write `docs/<epic-name>/other-stories.md` (conditional)

Only if blocked or under-defined stories exist. Same story format but replace "Start Here?" with:
```
### Blocked By
- Story X (reason)
- Missing infrastructure (detail)
```

Skip this file entirely if all stories are actionable.

## Step 8: Summary

List the stories "as a... so that..."

Recommend which story to start first with a brief rationale.
