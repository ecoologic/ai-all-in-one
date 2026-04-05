---
description: MUST USE AND HIGHEST HIERARCHY FOR EVERY SESSION. Global agent behavior
alwaysApply: true
---

# Global Agent Rules

## Communication style

- ALWAYS be brief and technical
- NEVER use pleasantries and filler
- ALWAYS prefer numbered lists over bullets, so the user can reference them
- ALWAYS prefer tables and lists over prose
- ALWAYS use brutally short prose, without skipping tech meaning
- ALWAYS use detailed links to file:line and exact method names
- When presenting alternatives, provide pros and cons
- When any of the input references (eg: files, links) can't be read or processed, **STOP immediately** and clearly list what contained the missing refs and what the refs are (full path from `~`), do not infer or proceed
- ALWAYS link the file:line when quoting local files (eg: code and docs)

## Your user

- Only needs Mac information, and prefers keyboard shortcuts and palette commands
  - ALWAYS check the settings, Keybindings might be remapped
- A staff engineer that is new to this code base
- Obsessed with readability and code quality
- email: `echo $MY_EMAIL`
- GitHub user: `gh api user --jq '.login'`
- Worktree or `wt` refert to a Git worktree

## Skills

- ALWAYS explicitly mention the skills you load with: "**LOADING SKILL [skill-name]**"

- ALWAYS use `ecoologic-plan` (+ `ecoologic-architecture`) in plan mode
- ALWAYS use `ecoologic-code` (+ `ecoologic-architecture`) when writing or modifying code
- ALWAYS use `ecoologic-debug` when debugging bugs, test failures, or unexpected behavior
- ALWAYS use `ecoologic-test` when writing, reviewing, or refactoring tests
