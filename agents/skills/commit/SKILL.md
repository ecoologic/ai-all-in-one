---
name: commit
description: 'Use when writing a git commit message for already staged changes, including explicit amend requests. Only standardize the title as a conventional commit.'
---

### Instructions

Only enforce the commit title format.

Commit all already staged changes without asking the user to confirm scope.

Use only the changes that are already staged.

Do not stage, unstage, or expand the commit scope.

Let the AI write the commit body and footer normally from the staged changes.

Treat the current staged set as the source of truth for commit scope.

If the session includes agile terminology such as a user story, story, or acceptance criteria, use that context to shape the commit message wording when it matches the staged changes.

Do not pause, warn, or ask for reconfirmation just because the staged set differs from an earlier snapshot, repo status output, or assumptions from prior turns.

If the user explicitly asks to amend, amend the current `HEAD` commit instead of creating a new commit.

If the user explicitly asks to update the full message while amending, replace the entire commit message, not just the title.

### Workflow

1. Inspect only the staged changes, for example with `git diff --cached`.
    If no changes, STOP and tell the prompter
2. Do not run `git add` or other commands to change the cached state.
3. Unless the user explicitly asks to split, narrow, or confirm commit scope, proceed with the staged set exactly as inspected.
4. If the user explicitly asks to amend, inspect the current `HEAD` commit message so the replacement message matches the final amended commit.
5. Decide the best conventional-commit `type` and the optional `scope`.
6. If the session includes a user story or acceptance criteria that match the staged changes, write a short first line in conventional-commit format that focuses on the feature improvement rather than the implementation detail.
7. In the rest of the commit message, include the full relevant story or acceptance criteria first, then add the technical details from the staged changes.
8. If the user explicitly asked to amend, run `git commit --amend`.
9. If the user explicitly asked to update the full message, replace the whole message during the amend instead of preserving any existing title, body, or footer.
10. Otherwise create a normal new commit.

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

If user-story or acceptance-criteria context is available in the session and matches the staged changes, prefer a short feature-oriented title and keep the fuller story and criteria in the body.

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
- Agile context from the session may shape the wording, but only when it matches the already staged changes.
- Do not treat differences from earlier snapshots or prior expectations as a reason to block the commit.
- When amending with a full-message update, make the replacement message fit the final amended commit, not just the newly staged delta.
- NEVER write titles like "addressing feedback", instead, stick to what work was done and summarise that as usual

### Final Step

Commit exactly the changes that are already staged. Use the conventional-commit format for the first line only. When matching user-story or acceptance-criteria context exists in the session, keep that first line short and feature-focused, then put the full story or criteria first in the body and the technical details after that.

Do not ask whether newly noticed staged files are intentional unless the user explicitly asked for scope confirmation or subset selection.

If the user explicitly requested amend, amend `HEAD` with those staged changes.

If the user explicitly requested a full-message update during amend, replace the entire commit message.
