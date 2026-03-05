---
description: Break down an epic into actionable user stories
argument-hint: <epic-slug>
allowed-tools: [Read, Write, Edit, AskUserQuestion]
---

# Epic

This command is a single step of a longer pipeline:
```
p-epic -> p-personas -> p-architecture -> p-story(s) -> p-task(s-t)
^current
```
Next: `/p-architecture` (personas step is optional)

### Pipeline I/O

| Direction | File                                 | Description             |
| --------- | ------------------------------------ | ----------------------- |
| **In**    | `./tmp/planning/<epic-slug>/idea.md` | Raw epic idea           |
| **In/Out** | `./tmp/planning/glossary.md`        | Shared glossary (read for consistent naming, updated with new terms) |
| **Out**   | `./tmp/planning/<epic-slug>/epic.md` | Structured user stories |

## Skills

Invoke these skills during execution via Skill tool:
- `lovable` if `ideas.md` links a Lovable project
- `ux-laws`

## Purpose

Break down a broad epic into actionable user stories FOCUSED ON USER EXPERIENCE, not tech like "create a DB table". Describe in a structured format how a feature is used and for what purpose. Each user story will be implemented individually via `/p-story`.

**This command produces documentation only. No code. No commits.**

## Rules

- NEVER write or modify application code, create commits, or write files outside `./tmp/planning/`
- NEVER define synonyms — if a term exists in the glossary, use its exact Code Name everywhere. One concept = one name
- NEVER abbreviate new names — use the domain's exact terms (`team-management`, not `team-mgmt`; `UserProfile`, not `UsrProf`)
- NEVER propose extractions for hypothetical future use (YAGNI)
- NEVER start implementation after generating planning artifacts

## Anti-Patterns

ANTI-PATTERN CHECK — verify each story does NOT match any of the following:

- NEVER read, write, or generate code
- NEVER investigate the codebase (no Glob, Grep, or file reads outside the planning directory)
- NEVER slice stories by technology layer (frontend, backend, database). Slice by vertical user-facing value
- NEVER write implementation details, API designs, or database schemas in stories
- NEVER frame stories from the builder's perspective ("As a developer, I want to create a DB table...")

## What is a _user story_

> A user story is a short, plain-language description of a capability told from the perspective of someone who uses the system — not someone who builds it. It follows the template "As a [persona], I want [goal] so that [benefit]" and describes what the user can do and why it matters, never how it's implemented. Each story should be small enough to complete in a single iteration, deliver standalone value (a new ability the user didn't have before), and be independently testable. The written story is a placeholder for a conversation, not a full specification. Good stories follow the INVEST criteria: Independent, Negotiable, Valuable, Estimable, Small, and Testable.

## What a _user story_ is NOT

> A user story is not a technical task or implementation detail. "As a developer, I want to create a DB table" is not a user story — it describes work for the builder, not value for the user. Items like "set up an API endpoint," "refactor the auth module," or "add a database index" are technical tasks (subtasks of a story or separate backlog items), not stories. Slicing stories by technology layer (frontend, backend) instead of vertical user-facing slices is an anti-pattern. A user story is also not a detailed spec — overloading it with implementation details defeats its purpose. Not everything in a backlog needs to be a user story; purely technical work should use a different format.

## Scope and size of a user story

<!-- TODO: formatting, examples -->

Stories should be small. For example, each of the CRUD operations should be _at most_ one story.

Work that has _low cohesion_ must be treated as a different story. For example, uploading a picture in your profile, is technically different from regular properties, so it should be treated as a separate story.

Even a simple dropdown or a text field, might become its own story if they depend on other work that relates to another story.

Even a table column might become its own feature if the data it displays is a big piece of work that belongs to another story. A story doesn't need to create all fields at the same time, a story can be split so that the field is added in another story. For example, a profile _doesn't need_ to have an address when it's first created, unless it's simple enough, like basic fields that don't require too much validation like `githubUrl`.

If a table cell has a link to an un-existing page, one story might be to print the table without the link, and successive story can add a working link to the page subject of the latter story.

If a page has tabbing, the first story might implement the page without any tabbing, and the second story might add it. OR we can have a tabbing system with one tab. In these situations, the best approach is to **ask the prompter**.

### When and how to split a story
<!-- TODO: is this section effective? -->

Ask yourself the questions:
1. is this shippable as a cohesive, complete and usable feature?
2. Are all the fields models etc _required and used_ for the work we're doing?

It is OK to return to the same UI to add a field in a different story.

## Step 0: Load glossary

Read `./tmp/planning/glossary.md` if it exists. Use its terms and Code Names consistently throughout all outputs. Never introduce alternative names for glossary terms.

## Step 1: Resolve epic input

`$ARGUMENTS` = `<epic-slug>`

Read the idea file at `./tmp/planning/<epic-slug>/idea.md`.

If `idea.md` does not exist at that path, report the exact path checked and stop. Do not fall back to other input modes.

Output:
```
Epic slug: <epic-slug>
Epic: <one paragraph summary from idea.md>
```

## Step 2: Resolve docs path

All artifacts go in: `./tmp/planning/<epic-slug>/`

Create the directory if it doesn't exist.

Output:
```
Docs path: ./tmp/planning/<epic-slug>/
Status: <created | already exists>
```

## Step 3: Break into user stories

<!-- TODO: multiagent? eg: Launch up to 3 explore agents **in parallel**: then 3a, 3b 3c -->

Keeping in mind what a user story is and what is not (above), split the work into user stories. For each:
- Canonical format: _As a_ [role], _I want_ [action], _so that_ [benefit]
- User Context section (role, goals, use case)
- Acceptance criteria in _Given_/_When_/_Then_ format as markdown checkboxes `- [ ]`
- Requirements where relevant (performance, security, accessibility)
- Assess prerequisites: does this depend on another story or missing infrastructure?

Output: Display each story title and its canonical "As a..." statement before proceeding to classification.

## Step 4: Classify and evaluate

Separate into two groups:
1. **Actionable** — no prerequisites, can start now given current codebase
2. **Blocked** — depends on other stories or missing infrastructure

Output: Display the classification table (story title, group, rationale) before proceeding.

<!-- TODO: group stories, more explicit? -->

## Step 5: Write stories to `./tmp/planning/<epic-slug>/epic.md`

The following notes apply to the Fields and UX considerations sections inside each story:

- **Fields**: DO NOT look at the code to determine fields. Derive fields from the UI, provided docs, or by clarifying with the user. List all fields in the user experience grouped by page/view.
- **UX considerations**: Even with a UI design, assume inconsistencies exist. Avoid making too many assumptions — defer to implementation where code can be checked for consistency.

Create the file with this structure:

```md
# <Epic Name> (<epic-slug>) — Actionable Stories

> Epic: <summary>
> Generated: <date>

## Story 1: <title>(short) example: Create user</title>

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

### Fields

- [List all the fields in the user experience grouped by page/view]
      - Format:
            - _Field_: Exact and precise Source or reason (where did you find this field, why do we need it). This can be just a link
      - Example:
            - _User name_: As per UI design provided in `./tmp/planning/<epic-slug>/design.md`

### Requirements
- list

### UX considerations (by story or can be grouped for several similar stories)
- list
---
```

If links to documentation, UI, or context exist, add them at the bottom of the file in a `## References` section.

## Step 6: Update glossary

Add new domain terms discovered during this step to `./tmp/planning/glossary.md`. Create the file if it doesn't exist. Never remove existing entries. Never rename existing terms — ask the user if there's a conflict.

At this stage, Code Name and Source will typically be `—` (resolved later by p-architecture). Status should be `new` for terms not yet in codebase.

## Step 7: Present to user
<!-- TODO: make it easy for the user to review all names (models, fields, titles etc) -->

Display a structured summary via `AskUserQuestion`:

1. **Story count**: X actionable, Y blocked
2. **Recommended starter**: Story N — because [rationale]
3. **Assumptions made**: List any assumptions that need validation
4. **Open questions**: List anything that needs clarification before proceeding

Implementation happens in later pipeline steps.

## Success Criteria

- [ ] `epic.md` exists at `./tmp/planning/<epic-slug>/epic.md`
- [ ] Every story uses canonical format: _As a_ [role], _I want_ [action], _so that_ [benefit]
- [ ] Every story has acceptance criteria in _Given_/_When_/_Then_ format
- [ ] Every story has Fields and UX considerations sections
- [ ] Every story respects its definition "What a story is"
- [ ] Every story respects the definition "What a story is _not_"
- [ ] Every story is "minimal", broken into the minimum valuable iteration
- [ ] Stories are classified as actionable or blocked
- [ ] No story is sliced by technology layer
- [ ] `glossary.md` at `./tmp/planning/glossary.md` is created or updated with new domain terms
- [ ] No synonyms — every concept has exactly one name, consistent with the glossary
- [ ] User has reviewed and approved the stories

## Error handling

- **Empty arguments** — Ask the user to provide an epic slug
- **`idea.md` does not exist** — Report the exact path checked (`./tmp/planning/<epic-slug>/idea.md`), ask the user to create it first
