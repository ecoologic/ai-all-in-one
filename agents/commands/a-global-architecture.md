---
description: Map the repo-wide architecture and write the shared glossary and global architecture artifacts
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, Skill, AskUserQuestion]
---

# Global Architecture

This command creates and maintains the shared planning context used by all epic-specific commands:
```text
a-global-architecture -> a-epic -> a-architecture -> a-story(s) -> a-task(s)
^current
```

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | codebase | Read-only repo structure, conventions, modules, contracts, and domain language |
| **In** | durable repo docs | Product docs, architecture docs, ADRs, README files, and stable references |
| **Out** | `./tmp/planning/global-architecture.md` | Lean cross-epic map of major system areas, boundaries, and communication paths |
| **Out** | `./tmp/planning/glossary.md` | Shared domain glossary with canonical names, code names, sources, and statuses |

## Purpose

Build the shared planning baseline before epic-specific work begins.

This command owns two cross-epic artifacts:
- `global-architecture.md` for structure and communication paths
- `glossary.md` for domain language and canonical naming

Later commands may refine them, but this command is the baseline producer.

## Skills

Use these skills when relevant:
- `explore` for repo-wide discovery
- `architecture-blueprint-generator` for structural mapping
- `ecoologic-code` for naming and convention alignment
- `software-architecture-design` when summarizing durable system boundaries
- `mermaid-diagrams` if diagrams materially improve the repo map

## Rules

- NEVER write or modify application code
- NEVER put epic-specific rationale into `global-architecture.md`
- NEVER put temporary aliases or speculative names into `glossary.md`
- NEVER define synonyms for the same concept
- prefer durable structure over local implementation noise
- prefer code and stable project conventions over aspirational docs when they disagree

## Step 1: Explore the repo-wide structure

Inspect the codebase and stable docs to identify:
- major apps, services, packages, and modules
- responsibilities and ownership boundaries
- communication paths between major parts
- stable integrations and infrastructure touchpoints
- durable shared contracts
- cross-epic domain language already present in docs or code

Use targeted exploration with parallel agents when helpful, but keep the result focused on durable shared context.

## Step 2: Build the glossary

Write `./tmp/planning/glossary.md` as the canonical shared naming artifact.

Use this structure:

```md
# Glossary

> Generated: <date>

| Domain Term | Code Name | Definition | Source | Status |
| ----------- | --------- | ---------- | ------ | ------ |
| ... | ... | ... | ... | ... |
```

Rules:
- **Domain Term** is the human planning term to use across commands
- **Code Name** is the current code-level name, or `—` if not yet implemented
- **Source** points to the file, module, doc, or artifact that justifies the row
- **Status** should be `exists`, `new`, `rename-request`, or `exists (extend with ...)`

Only include durable terms that later planning and implementation work should inherit.

## Step 3: Build the global architecture map

Write `./tmp/planning/global-architecture.md` as a lean cross-epic map.

Use this structure:

```md
# Global Architecture

> Generated: <date>

## Major System Areas
### <area>
- responsibility
- key boundaries

## Communication Paths
- `ui -> api`
- `api -> db`
- ...

## Stable Contracts And Integrations
- ...

## Shared Constraints
- ...

## References
- ...
```

Do not include:
- current epic goals
- story-specific design detail
- temporary assumptions
- local implementation notes that do not matter across epics

## Step 4: Present to user

Summarize:
1. major system areas identified
2. key communication paths
3. glossary terms created or updated
4. open conflicts or rename requests

Ask the user to review before epic-specific planning begins.

## Success Criteria

- [ ] `./tmp/planning/global-architecture.md` exists
- [ ] `./tmp/planning/glossary.md` exists
- [ ] the architecture file is lean and cross-epic
- [ ] the glossary is domain-based and canonical
- [ ] no synonyms were introduced
- [ ] the user reviewed the shared artifacts before moving on

## Error Handling

- **No meaningful codebase structure found** — say so explicitly and produce the leanest truthful map possible
- **Naming conflicts found** — record them as conflicts or rename requests instead of choosing silently
- **Docs and code disagree** — prefer the codebase, record the disagreement, and surface it to the user
