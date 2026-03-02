---
description: Use to break down an epic into actionable user stories grounded in the current codebase
argument-hint: <file-path-or-epic-description>
allowed-tools: [Read, Glob, Grep, Write, Edit, TaskCreate, TaskUpdate, TaskList]
---

# Epic command

You are breaking down a broad epic into actionable, FOCUSED ON USER EXPERIENCE, not tech like "create a DB table". Coding and codebase investigation is completely _forbidden_ for this command.

The purpose of this command is to describe in a structured format how a feature is used and for what purpose, it's NOT to produce any code. Only documentation. This command ends with the creation of the user stories document. Each user story will be implemented individually as a separate command.

This command is part of a process, `/epic -> /story -> task`.

## What is a _user story_

**SUPER IMPORTANT**

> A user story is a short, plain-language description of a capability told from the perspective of someone who uses the system — not someone who builds it. It follows the template "As a [persona], I want [goal] so that [benefit]" and describes what the user can do and why it matters, never how it's implemented. Each story should be small enough to complete in a single iteration, deliver standalone value (a new ability the user didn't have before), and be independently testable. The written story is a placeholder for a conversation, not a full specification. Good stories follow the INVEST criteria: Independent, Negotiable, Valuable, Estimable, Small, and Testable.

## What a _user story_ is NOT

**SUPER IMPORTANT**

> A user story is not a technical task or implementation detail. "As a developer, I want to create a DB table" is not a user story — it describes work for the builder, not value for the user. Items like "set up an API endpoint," "refactor the auth module," or "add a database index" are technical tasks (subtasks of a story or separate backlog items), not stories. Slicing stories by technology layer (frontend, backend) instead of vertical user-facing slices is an anti-pattern. A user story is also not a detailed spec — overloading it with implementation details defeats its purpose. Not everything in a backlog needs to be a user story; purely technical work should use a different format.

## Scope of a user story

<!-- TODO: formatting, examples -->

Stories should be small. For example, each of the CRUD operations should be _at most_ one story.

Work that has _low cohesion_ must be treated as a different story. For example, uploading a picture in your profile, is technically different from regular properties, so it should be treated as a separate story.

Even a simple dropdown or a text field, might become its own story if they depend on other work that relates to another story.

Even a table column might become its own feature if the data it displays is a big piece of work that belongs to another story.

## When to split a story

<!-- TODO: part of the review step -->
Ask the question: is this shippable as a cohesive, complete and usable feature?

It is OK to return to the same UI to add a field in a different story.

## Step 1: Resolve epic input

Determine the epic source from `$ARGUMENTS`:
- **File path** project relative, or absolute
- **Inline text** (non-empty, not a file path): use it directly as the epic
- **Empty**: synthesize the epic from current conversation context — output your summary and ask the user to confirm before continuing

Output:
```
Epic: <one-line summary>
```

## Step 2: Derive epic slug

From the epic content, derive a slugified `<epic-slug>` (lowercase, hyphens, no special chars).
Example: "user authentication system" → `user-auth`

NOTE: _epic_, _feature_, _delivery_ and the like are not good pre/suffixes.

## Step 3: Break into user stories

Keeping in mind what a user story is and what is not (above), split the work into user stories. For each:
- Canonical format: _As a_ [role], _I want_ [action], _so that_ [benefit]
- User Context section (role, goals, use case)
- Acceptance criteria in _Given_/_When_/_Then_ format as markdown checkboxes `- [ ]`
- Requirements where relevant (performance, security, accessibility)
- Assess prerequisites: does this depend on another story or missing infrastructure?

## Step 4: Classify and evaluate

Separate into two groups:
1. **Actionable** — no prerequisites, can start now given current codebase
2. **Blocked** — depends on other stories or missing infrastructure

For each actionable story, add *Pros* and *Cons* of starting with that story first.

## Step 6: Write `docs/<epic-slug>/stories.md`

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

### UX considerations
- (only if relevant)
---
```

## Step 8: Summary

List the stories "as a... so that..."

Recommend which story to start first with a brief rationale.
