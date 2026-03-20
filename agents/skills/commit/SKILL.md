---
name: commit
description: 'Use when writing a git commit message for already staged changes, including explicit amend requests. Only standardize the title as a conventional commit.'
---

### Instructions

Only enforce the commit title format.

Operate only within the current project root git repository.

If there are nested git repositories inside that root, ignore them.

If the current project root sits inside a parent git repository, ignore the parent repository too.

Use only the changes that are already staged.

Do not stage, unstage, or expand the commit scope.

Let the AI write the commit body and footer normally from the staged changes.

Treat the current staged set as the source of truth for commit scope.

Do not pause, warn, or ask for reconfirmation just because the staged set differs from an earlier snapshot, repo status output, or assumptions from prior turns.

If the user explicitly asks to amend, amend the current `HEAD` commit instead of creating a new commit.

If the user explicitly asks to update the full message while amending, replace the entire commit message, not just the title.

### Workflow

1. Confirm which git repository is the current project root and commit only there.
    Never commit from a parent repository and never descend into nested repositories to commit there.
2. Inspect only the staged changes for that root repository, for example with `git diff --cached`.
    If no changes, STOP and tell the prompter
3. Do not run `git add` or other commands to change the cached state.
4. Unless the user explicitly asks to split, narrow, or confirm commit scope, proceed with the staged set exactly as inspected.
5. If the user explicitly asks to amend, inspect the current `HEAD` commit message so the replacement message matches the final amended commit.
6. Decide the best conventional-commit `type` and the optional `scope`.
7. Write only the first line in conventional-commit format.
8. Keep the rest of the commit message freeform and useful.
9. If the user explicitly asked to amend, run `git commit --amend`.
10. If the user explicitly asked to update the full message, replace the whole message during the amend instead of preserving any existing title, body, or footer.
11. Otherwise create a normal new commit.

### Commit Message Structure

Title only:

```text
type: short summary
```

Optional:

```text
type(scope): short summary
```

When the staged change centers on one specific code element, prefer naming that element directly over restating it in prose. Good summaries often use a file name without the full path or extension, an object or type name, a method name, an endpoint, or another concrete identifier. Avoid duplicating the same idea twice, for example `feat: createUser` instead of `feat: createUser create a new user`.

### Examples

```text
refactor: userById() accepting strings
# Note below the message is positive, less about what was broken, more about what now works. Let the body explain that
# Note the tech level of the API endpoint
fix(api): GET /users -> 200 when there are no users
docs: README new Development section
docs: README Development section with server URLs
# Note that often a small commit coincides with the addition (or change) of a method
feat: CreateUser
```

### Validation

- Use a standard type: `feat`, `fix`, `docs`, `style`, `refactor`, `rename`, `perf`, `test`, `build`, `ci`, `chore`, or `revert`.
- Keep the summary short and specific.
- Only the title must follow this format.
- Base the message only on already staged changes.
- Never cross repository boundaries: do not commit a parent repo and do not commit nested repos.
- Do not treat differences from earlier snapshots or prior expectations as a reason to block the commit.
- When amending with a full-message update, make the replacement message fit the final amended commit, not just the newly staged delta.
- NEVER write titles like "addressing feedback", instead, stick to what work was done and summarise that as usual

### Final Step

Commit exactly the changes that are already staged. Use the conventional-commit format for the first line only, then write the rest of the message however best explains those staged changes.

Do not ask whether newly noticed staged files are intentional unless the user explicitly asked for scope confirmation or subset selection.

If the user explicitly requested amend, amend `HEAD` with those staged changes.

If the user explicitly requested a full-message update during amend, replace the entire commit message.
