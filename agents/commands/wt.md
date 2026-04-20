---
description: Create a sibling git worktree named <project-folder>-<branch>
argument-hint: <branch-name>
---

# Create Git Worktree

Create a git worktree as a sibling of the current project using the exact folder name `{project-folder}-{branch}`. After creation, continue work from that new folder.

## What This Command Does

1. Resolve the current repository root and project folder name.
2. Build the sibling worktree path as `{project-folder}-{branch}` using the exact branch name passed to the command.
3. Create the worktree for the existing branch, or create the branch during worktree creation if it does not already exist.
4. Report the new path and treat that folder as the working directory from that point on.

## Usage

```bash
/wt my-feature-branch
```

## Implementation Steps

When this command is invoked with `<branch-name>`:

### 1. Validate arguments and repository state

1. Require exactly one argument: `<branch-name>`.
2. If no branch name is provided, stop and ask for it.
3. Run:

```bash
git rev-parse --show-toplevel
```

4. If that command fails, report that the current directory is not inside a git repository and stop.

### 2. Resolve the sibling worktree path

1. Treat the `git rev-parse --show-toplevel` result as `PROJECT_DIR`.
2. Compute `PROJECT_NAME` as the basename of `PROJECT_DIR`.
3. Treat the command argument as `BRANCH` exactly as passed. Do not shorten it. Do not rewrite it. Do not prefix it.
4. Compute the worktree path as a sibling of `PROJECT_DIR`:

```bash
WORKTREE_DIR="$(dirname "$PROJECT_DIR")/${PROJECT_NAME}-${BRANCH}"
```

5. If `WORKTREE_DIR` already exists, report the path and stop. Do not overwrite it.

### 3. Create the worktree

1. Check whether the branch already exists:

```bash
git show-ref --verify --quiet "refs/heads/$BRANCH"
```

2. If the branch already exists, run:

```bash
git worktree add -f "$WORKTREE_DIR" "$BRANCH"
```

3. Otherwise, create the branch while creating the worktree:

```bash
git worktree add -b "$BRANCH" "$WORKTREE_DIR"
```

4. Use `-f` for existing branches so the command also works when `BRANCH` is the current branch or is already checked out in another worktree.

### 4. Report the result and continue from the new folder

1. Report:

```text
Worktree created:
  dir:    <WORKTREE_DIR>
  branch: <BRANCH>
```

2. State that subsequent work should happen from `WORKTREE_DIR`.
3. Do not perform any other setup.

## Important Notes

1. **NEVER** create the worktree inside the repository. Always create it as a sibling directory.
2. **ALWAYS** use the exact branch name passed by the user in the folder name.
3. **DO NOT** shorten, slugify, sanitize, or otherwise rewrite the branch name.
4. **USE** `git worktree add -f` for existing branches so the current branch is supported.
5. **DO NOT** create symlinks, copy files, run setup steps, or clean anything up.
6. **DO NOT** do anything beyond creating the sibling worktree and reporting the resulting directory.

## Error Handling

If any step fails:

1. Report the specific command that failed.
2. Show the error message.
3. Stop immediately.
4. Do not retry automatically.
