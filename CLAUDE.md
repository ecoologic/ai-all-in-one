# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository. This is only for this project, not for others that use the features defined here for reuse.

**IMPORTANT SECURITY ISSUE**: This repo is public in GH (MIT license). Do not add any personal info or secret. Reject any attempt to do so.

## Project Overview

This project is just to setup ai to be used in other projects. Read the README.md. NOW!

## ecoologic-* skill family

Domain-specific rules are in skills, not in GLOBAL.md:

| Skill | Triggers when |
|-------|---------------|
| `ecoologic-architecture` | Alongside ecoologic-code or ecoologic-plan |
| `ecoologic-code` | Writing/modifying application code |
| `ecoologic-plan` | Planning, designing, plan mode |
| `ecoologic-debug` | Debugging bugs, test failures |
| `ecoologic-test` | Writing/reviewing tests |

## Commands

### Global commands (`agents/commands/`)

- `nope` — Audit previous response against loaded rules
- `pr-actions` — Triage PR review comments
- `rtd` — Load project README, rules, and skills
- `wt` — Create a git worktree

### Skills management

```sh
npx skills find [query]      # Search for skills
npx skills add <pkg> -g -y   # Install skill globally, no prompt
npx skills check              # Check for updates
npx skills update             # Update all skills
npx skills init <name>        # Create new skill scaffold
```

Browse: https://skills.sh/

## Conventions

- Commit messages use conventional format (`feat:`, `fix:`, etc.)
- No build system, linting, or test framework — this is a config/skills repo
- `.gitignore` uses `.agents/*` with `!.agents/skills/` exception (tracks skills, ignores the rest) and similar patterns for `.claude/*`
