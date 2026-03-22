---
description: Load and internalize the project README, rules, and skills for both Claude and Cursor
---

# Read The Docs

Bootstrap project context by reading all standard configuration files for both Claude Code and Cursor. This ensures the agent fully understands the project before doing any work.

## Implementation Steps

When this command is invoked:

### 1. Read project root context files

Read each file below **if it exists** — skip silently if missing:

```
README.md
CLAUDE.md
AGENTS.md
CONTRIBUTING.md
```

### 2. Read Claude Code project config

Read each file below if it exists:

```
.claude/CLAUDE.md
.claude/settings.json
.claude/settings.local.json
```

### 3. Read Cursor project config

Read each file below if it exists:

```
.cursor/rules/*.md
.cursor/rules/*.mdc
```

### 4. Discover skills (global + project)

List skill directories found in each location below (directory names only):

**Global skills** (shared across all projects):

```
~/.agents/skills/
```

**Project-local skills** (only in this repo):

```
.agents/skills/
.claude/skills/
.cursor/skills/
```

For each skill found, read its `SKILL.md` frontmatter (first 10 lines) to capture name and description.

List skill files found in each location below (filenames only):

**DO NOT list built-in or internal commands** (eg: `/help`, `/clear`, `/config`) — only list user-created `.md` command files.

### 5. Report

Output a compact summary listing **every file that was actually read**, grouped by category:

```
## Project Context Loaded

**Root docs**:
- README.md ✓
- CLAUDE.md ✓
- AGENTS.md ✗ (not found)
- CONTRIBUTING.md ✗ (not found)

**Claude config**:
- .claude/CLAUDE.md ✓
- .claude/settings.json ✗ (not found)

**Cursor config**:
- .cursor/rules/ → [list of .md/.mdc filenames, or "none"]

**Global skills**: [name — description] for each, or "none"
**Project skills**: [name — description] for each, or "none"

**Files read**: [total count]
```

Mark each file with ✓ (read) or ✗ (not found). This is the full manifest of what was loaded.
## Important Notes

- **DO NOT modify any files** — this is read-only
- **DO NOT skip README.md** — if it exists, it must be read in full
- **DO NOT summarize file contents back to the user** — internalize them silently, only output the report above
- If a CLAUDE.md or rules file contains instructions, **follow them for the rest of the conversation**, and **remember to call appropriate skills**
