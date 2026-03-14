---
name: commit
description: 'Use when writing a git commit message for already staged changes, including explicit amend requests. Only standardize the title as a conventional commit.'
---

### Instructions

Only enforce the commit title format.

Use only the changes that are already staged.

Do not stage, unstage, or expand the commit scope.

Let the AI write the commit body and footer normally from the staged changes.

If the user explicitly asks to amend, amend the current `HEAD` commit instead of creating a new commit.

If the user explicitly asks to update the full message while amending, replace the entire commit message, not just the title.

### Workflow

1. Inspect only the staged changes, for example with `git diff --cached`.
    If no changes, STOP and tell the prompter
2. Do not run `git add` or other commands to change the cached state.
3. If the user explicitly asks to amend, inspect the current `HEAD` commit message so the replacement message matches the final amended commit.
4. Decide the best conventional-commit `type` and the optional `scope`.
5. Write only the first line in conventional-commit format.
6. Keep the rest of the commit message freeform and useful.
7. If the user explicitly asked to amend, run `git commit --amend`.
8. If the user explicitly asked to update the full message, replace the whole message during the amend instead of preserving any existing title, body, or footer.
9. Otherwise create a normal new commit.

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
- When amending with a full-message update, make the replacement message fit the final amended commit, not just the newly staged delta.

### Final Step

Commit exactly the changes that are already staged. Use the conventional-commit format for the first line only, then write the rest of the message however best explains those staged changes.

If the user explicitly requested amend, amend `HEAD` with those staged changes.

If the user explicitly requested a full-message update during amend, replace the entire commit message.
