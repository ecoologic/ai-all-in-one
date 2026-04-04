---
description: Create a git worktree following naming and symlink conventions
argument-hint: <branch-suffix>
---

# Create Git Worktree

Create an isolated git worktree as a sibling of the current project, following project conventions.

## Implementation Steps

When this command is invoked with `<branch-suffix>`:

### 1. Resolve project root and names

```bash
git rev-parse --show-toplevel
```

Extract:
- `PROJECT_DIR` — the full path (e.g. `/Users/erik/dev/my-app`)
- `PROJECT_NAME` — basename of `PROJECT_DIR` (e.g. `my-app`)

Derive:
- `WORKTREE_DIR` — `PROJECT_DIR`-`<branch-suffix>` (e.g. `/Users/erik/dev/my-app-auth-flow`)
- `BRANCH` — `<branch-suffix>` (e.g. `auth-flow`)

### 2. Validate

- Confirm `WORKTREE_DIR` does not already exist
- Confirm branch `BRANCH` does not already exist (unless user wants to check out an existing branch)

If either exists, report and ask how to proceed — do NOT overwrite.

### 3. Create the worktree

```bash
git worktree add -b <BRANCH> <WORKTREE_DIR>
```

This creates the worktree directory and the new branch in one step.

### 4. Symlink shared directories

From inside `WORKTREE_DIR`, symlink `planning/` and `tmp/` back to the original project so all branches share them:

```bash
ln -s <PROJECT_DIR>/planning <WORKTREE_DIR>/planning
ln -s <PROJECT_DIR>/tmp <WORKTREE_DIR>/tmp
```

Only symlink directories that exist in `PROJECT_DIR`. Skip silently if they don't.

### 5. Report

Output:
```
Worktree created:
  dir:    <WORKTREE_DIR>
  branch: <BRANCH>
  symlinks: planning/ tmp/ (if created)
```

## Important Notes

- **NEVER** create the worktree inside the project — always as a sibling directory
- Branch name is just the suffix, NOT prefixed with the project name
- Worktree folder IS prefixed with the full project path
- Only symlink `planning/` and `tmp/` — nothing else

## Error Handling

If `git worktree add` fails:
- Show the error
- Check if branch or directory already exists
- Report findings and stop
