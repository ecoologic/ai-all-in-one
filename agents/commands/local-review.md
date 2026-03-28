---
description: Gate on origin/main integration, run RTD then a strict local-only code review (no GitHub), offer saving to tmp/
---

# Local review

Run a **local-only** review of the current branch. **Do not run `git fetch`.** **Do not** use `gh`, GitHub API, browser to GitHub, PR comments, or any remote GitHub access for any reason.

## 0. Preconditions — stop or continue

1. Resolve the integration ref: use `origin/main` if `git rev-parse --verify origin/main` succeeds; otherwise use `main` if it exists locally. If neither exists, **stop** and report that `origin/main` or `main` is required (no fetch).

2. **Branch contains integration tip** (main merged or branch rebased onto main, using **existing** refs only):

   ```bash
   git merge-base --is-ancestor <integration-ref> HEAD
   ```

   Use `<integration-ref>` = `origin/main` or `main` from step 1.

   - If this command **fails** (non-zero): **stop immediately**. Do not run RTD or review. State clearly that `<integration-ref>` is not fully contained in `HEAD` — merge or rebase first, then retry.

   - If it **succeeds**: continue.

3. Record the current branch name for the closing step:

   ```bash
   git branch --show-current
   ```

   If empty (detached HEAD), use a safe fallback label like `detached` for the filename offer.

## 1. Read The Docs (`/rtd`)

Execute the full **Read The Docs** workflow defined in `agents/commands/rtd.md` (read-only bootstrap: root docs, Claude/Cursor config, skills manifest, report format). **Do not modify any files** in this phase.

## 2. Local code review only

Immediately after RTD completes, perform the code review pass **in this chat only**, following the intent of:

`/code-review:code-review ONLY review this branch locally with \`git diff origin/main\`, no GitHub interaction for any reason, Post results ONLY here in this chat, DO NOT comment or attempt to access GitHub`

Adapt the diff command to the integration ref you actually use:

- If `origin/main` exists: base the review on **`git diff origin/main HEAD`** (full branch vs that ref). If the user’s environment truly requires the one-argument form, use **`git diff origin/main`** only when it matches the same comparison intent; prefer **`git diff origin/main HEAD`** for reviewing the branch tip.

- If you fell back to local `main`: use **`git diff main HEAD`** (still no fetch, no GitHub).

**Hard bans:** no `gh`, no GitHub URLs, no PR/issue/comment APIs, no suggesting or performing actions on GitHub. Output the review **only** in the current conversation.

## 3. Close — optional save

Offer to write the combined RTD report plus the review to:

```text
tmp/<branch-name>.md
```

Use the branch name from §0.3; replace `/` and other path-hostile characters with `-`. Create `tmp/` if needed (`mkdir -p tmp`). Only write if the user accepts.
