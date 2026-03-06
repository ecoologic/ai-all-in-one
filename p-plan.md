# Planning Pipeline

## TODOs

* Idea: `p-idea` to brainstorm??
* eg: `p-epic` finds epic for later
  * Nice-to-have

## Flow

```
p-epic -> p-personas -> p-architecture -> p-story(s) -> p-task(s-t)
```

## Shared Rules

All `p-` commands MUST follow these rules. Each command inlines its own copy of these rules for self-contained execution.

### Glossary

The shared glossary at `./tmp/planning/glossary.md` is the single source of truth for domain terminology.

**Every `p-` command must:**
1. Read `./tmp/planning/glossary.md` at the start (if it exists)
2. Use glossary terms and Code Names consistently throughout all outputs
3. Add new domain terms discovered during execution
4. Never remove existing entries
5. Never rename existing terms — ask the user if there's a conflict

**Glossary table format:**

```markdown
# Glossary
> Last updated: <date>

| Domain Term | Code Name | Definition | Source | Status |
| ----------- | --------- | ---------- | ------ | ------ |
```

- **Code Name**: actual class/type/table name in code (or `—` if not yet in codebase)
- **Source**: file path where it exists (or `—` if new)
- **Status**: `exists` | `new` | `rename` | `exists (extend with ...)`

**Progressive enrichment:** Earlier commands (p-epic) may leave Code Name/Source as `—`. Later commands (p-architecture, p-story) fill them in as codebase is explored.

### Global Architecture

The global architecture map at `./tmp/planning/global-architecture.md` is the single source of truth for project structure.

**Commands that explore the codebase (`p-architecture`, `p-story`) must:**
1. Read `./tmp/planning/global-architecture.md` at the start (if it exists)
2. Merge new structural findings back into it before finishing
3. Edit inline in the relevant section — never append a changelog

### Naming

- NEVER define synonyms — if a term exists in the glossary, use its exact Code Name everywhere. One concept = one name
- NEVER abbreviate names — use the domain's exact terms (`team-management`, not `team-mgmt`; `Invitation`, not `Invite`)
- Slugs use full words separated by hyphens

### Scope boundaries

- NEVER write or modify application code from any `p-` command (code is written only in `p-task`)
- NEVER write files outside `./tmp/planning/` (except `p-task` which writes to codebase)
- NEVER propose extractions for hypothetical future use (YAGNI)
- NEVER start implementation after generating planning artifacts

### QA ideas

`p-task` (and any steps after it) may discover bugs in code **we wrote** (i.e. code produced by earlier `p-task` runs in the same or a previous epic). Ignore issues from features not yet implemented.

When a bug is found, append it to `./tmp/planning/<epic-slug>/qa-ideas.md`:

```markdown
- [ ] **<short title>** — <description of the bug and where it was found> (`<file-path>:<line>`)
```

Create the file if it doesn't exist. Never remove existing entries.

### User checkpoints

Every `p-` command must present results to the user and get confirmation before the pipeline moves to the next step. No command auto-chains into the next.

### Pipeline I/O

Each command declares a Pipeline I/O table in its header. The glossary appears as `In/Out` in every command.

All artifacts live under `./tmp/planning/<epic-slug>/` except the glossary which is shared at `./tmp/planning/glossary.md`.

## Docs

AI should write the files even in plan mode (only in the `./tmp/<epic-slug>` folder), so I can review them there.

Call `/p-epic epic-slug`
Reads: `./tmp/planning/<epic-slug>/idea.md`
Writes: `./tmp/planning/<epic-slug>/epic.md`
Updates: `./tmp/planning/glossary.md`

idea.md is READ ONLY, can reference all required docs like ui etc
The folder of the docs defines the epic-slug.
Epic.md contains the list of stories (n. title, as a user I want...)

Call `/p-personas epic-slug`
Reads: `idea, epic`
Writes: `personas`
Edits: `epic` (updates personas in stories, improves "so that..." with persona context)
Updates: `glossary` (if new persona-related terms)

Call `/p-architecture epic-slug`
Reads: `idea, epic, glossary`
Reads: codebase (first command that can, but only read, no writes)
Writes: `architecture`
Updates: `glossary` (enriches Code Names, Sources, Statuses from codebase)

Call `/p-story epic-slug 1`
Reads: `epic, architecture, glossary`
Reads: codebase
Writes: `story-<n>/details`
Writes: `story-<n>/task-<n>`
Updates: `glossary` (fills in Code Names/Sources discovered during investigation)
Edits: `architecture` (addendum if new insights found)

Call `/p-task epic-slug 1-1`
Reads: `story-<n>/task-<n>, architecture, glossary`
Writes: codebase (first command that can write code)

## Commands details

Split into sub-agents when possible and set the model.

### Story

Further investigates patterns and common folders (eg: utils)
Defines tasks to extract code so it can be reused.
Defines new types

### Task
