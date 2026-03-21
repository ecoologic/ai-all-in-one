---
description: Rebase a stacked branch onto main after the parent branch was squash-merged
argument-hint: <parent-branch> [current-branch]
---

# Merge Stacked Branch

Safely rebase a stacked branch onto main after its parent branch was squash-merged. Uses `git rebase --onto` to replay only the unique commits, avoiding conflicts from replayed squashed commits.

## Arguments

- `$ARGUMENTS` contains: `<parent-branch> [current-branch]`
- Parse the first token as `PARENT_BRANCH` (required)
- Parse the second token as `CURRENT_BRANCH` (optional, defaults to current HEAD branch)

If no arguments provided, stop and ask the user for the parent branch name.

## Implementation Steps

### 1. Parse arguments and validate state

```bash
git status
```

- Ensure working tree is clean (no uncommitted changes). If dirty, stop and warn: "Stash or commit changes before proceeding."
- Determine `CURRENT_BRANCH` from `git branch --show-current` if not provided as second argument.

### 2. Fetch and update main

```bash
git fetch origin main:main
```

- This updates the local `main` ref without checking it out.
- If fetch fails, report the error and stop.

### 3. Resolve parent branch ref

Check if `PARENT_BRANCH` exists as a local ref:

```bash
git rev-parse --verify PARENT_BRANCH 2>/dev/null
```

If the parent branch ref exists locally:
- Use it directly as the rebase boundary.

If the parent branch ref does NOT exist locally:
- Show recent history to help the user identify the boundary commit:
  ```bash
  git log --oneline -20
  ```
- Ask the user: "Branch `PARENT_BRANCH` not found locally. Provide the last commit SHA from that branch (the commit just before your first unique commit on `CURRENT_BRANCH`)."
- Use the provided SHA in place of `PARENT_BRANCH` in the rebase command.

### 4. Run the rebase

```bash
git rebase --onto main PARENT_BRANCH CURRENT_BRANCH
```

- This replays only the commits between `PARENT_BRANCH` and `CURRENT_BRANCH` onto `main`.

If rebase succeeds:
- Report success: number of commits replayed, new base is `main`.

If rebase hits conflicts:
- **DO NOT resolve conflicts automatically.**
- Stop and report: "Rebase hit conflicts. Resolve them manually, then run `git rebase --continue`. Or abort with `git rebase --abort`."

### 5. Clean up stale parent branch

After successful rebase, check if `PARENT_BRANCH` still exists locally:

```bash
git branch --list PARENT_BRANCH
```

If it exists, ask the user: "Delete local branch `PARENT_BRANCH`? It was squash-merged into main and is no longer needed."

If the user confirms, delete it:

```bash
git branch -D PARENT_BRANCH
```

## Important Notes

- **NEVER force-push or modify main**
- **NEVER resolve rebase conflicts automatically** — let the user handle them
- **NEVER commit during this command** — it only rebases existing commits
- Working tree MUST be clean before starting
- If anything fails unexpectedly, report the error and stop

## Example

```
/merge partner-fields
```

Means: "I'm on my current branch. `partner-fields` was the parent that got squash-merged into main. Rebase only my unique commits onto main."

Expected flow:
1. Fetch latest main
2. Run `git rebase --onto main partner-fields HEAD`
3. Only commits after `partner-fields` are replayed onto main
4. Offer to delete `partner-fields` local branch
