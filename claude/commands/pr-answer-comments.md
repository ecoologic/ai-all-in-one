---
description: Fetch PR review comments, classify them, auto-reply as a pending review, and resolve outdated threads
---

# Get PR Review Comments & Auto-Reply

Fetch all unresolved review comments for a PR, group them by similarity, classify each, create a pending review with appropriate replies, and auto-resolve outdated threads. The pending review is only visible to you until submitted.

Argument: $ARGUMENTS

## Implementation Steps

### 1. Detect PR

If `$ARGUMENTS` is a number, use it as the PR number. Otherwise, detect from the current branch:

```bash
gh pr view --json number,url
```

If no PR is found, report the error and stop.

### 1b. Check for Existing Results

Check if a previous results file exists at `tmp/pr-comments-{pr-number}-round-*.md` using Glob. If one or more exist:

1. Read the latest round file (highest round number)
2. Present its contents to the user
3. Ask: **"Found previous round. Continue from here, or start fresh?"**
   - If continue: increment the round number for the new file
   - If fresh: start from round 1

If no previous file exists, proceed normally with round 1.

### 2. Fetch Review Comments (GraphQL)

Use GraphQL to get unresolved review threads with full context. **Include `id` fields for PR and threads** — these are needed for creating the pending review later. Run:

```bash
gh api graphql -f query='
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      id
      title
      url
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          startLine
          diffSide
          comments(first: 10) {
            nodes {
              id
              body
              author { login }
              createdAt
            }
          }
        }
      }
      comments(first: 50) {
        nodes {
          body
          author { login }
          createdAt
        }
      }
    }
  }
}' -f owner='{owner}' -f repo='{repo}' -F pr={number}
```

Replace `{owner}`, `{repo}`, and `{number}` with values from `gh repo view --json owner,name` and the PR number from step 1.

**Skip resolved threads** — only process threads where `isResolved: false`.

**Skip own comments** — completely ignore any comment or thread where the only commenter is `ecoologic` (the PR author). If a thread has comments from both `ecoologic` and other reviewers, only process the comments from other reviewers. Threads where every comment is from `ecoologic` should be excluded entirely.

**Skip already-replied threads** — if the latest comment in a thread is from `ecoologic`, check it:
- **Skip entirely** if the reply is semantically similar to the proposed reply (already addressed)
- **Skip entirely** if the reply contains any emoji (indicates acknowledgement/reaction)
- **Update the reply** otherwise — include the thread in the results so the pending review overwrites the previous reply with an improved one

### 3. Group Comments by Similarity

Analyze all unresolved comments and group them semantically:

- **Same feedback repeated across files** (e.g., multiple "add types", "rename this", "missing error handling")
- **Related concerns** (e.g., several comments about the same architectural issue)
- **Standalone comments** get their own group

Each group gets a short label describing the theme (e.g., "Type safety", "Naming", "Error handling", "Missing tests").

### 4. Order Groups by Diff Position

Sort groups by their earliest occurrence in the diff (top-to-bottom as seen in GitHub's Changes tab):

1. **Each group's position** = the earliest `(path, line)` of any comment in that group
2. **Order by file appearance** in the diff first, then by line number within that file
3. **Groups with only general comments** ignore

### 5. Classify Each Comment

For each comment, read the surrounding code context if needed and classify into one of three categories:

**Category A — Invalid / Not Actionable**: The comment is incorrect, based on a misunderstanding, not applicable, is praise, or is a question that doesn't require code changes. Examples:
- Reviewer misread the code
- The suggestion would break functionality
- It's a compliment or neutral observation

**Category B — Valid**: The comment is a legitimate, actionable request for this PR.

**Category C — NOOP (Pre-existing)**: The comment points at something that is valid but is a pre-existing pattern already used elsewhere in the codebase. To verify this, search the repo for similar patterns using Grep. Only classify as NOOP if you find clear evidence.

### 6. Present Results

Within each group, list comments in diff order. Include the classification and planned reply.

Output format:

```
## PR #<number>: <title>
<url>

### 1. [GROUP: <Label>] (<N> comments)

- `path/to/file.ts:42` [VALID] [OUTDATED] ← first in group
  `const foo = bar()` <- (the code line from the diff hunk, trimmed)
  > Comment text here -- @author
  **Reply**: VALID: I'll address this (#1).

- `path/to/file2.ts:99` [VALID] ← same issue, different location
  `const baz = bar()`
  > Same feedback again -- @author
  **Reply**: VALID: See https://github.com/owner/repo/pull/123#discussion_r1234 (link to first comment's thread)

- `path/to/other.ts:15` [NOOP]
  `function doThing() {`
  > Another comment in the same group -- @author
  **Reply**: NOOP: Pre-existing behaviour, I'm happy to take charge of this, but if we want to fix these, we should do that as a separate PR, so we can properly extract the logic.

- `path/to/another.ts:88` [INVALID]
  `return result`
  > This should use early return -- @author
  **Reply**: INVALID: This is actually already using early return -- the `result` variable is computed above and this is the only return path.

### General Comments (PR-level, not in a review thread)

Classify the same way (VALID/NOOP/INVALID) but **do not auto-reply** — these are issue-style comments with no pending review mechanism. Display for awareness only.

- > Comment body -- @author [VALID]
- > Another comment -- @author [NOOP]
- > Yet another -- @author [INVALID]
```

### 7. Ask for Confirmation

Present the full list with proposed replies. Ask:

**"Review the proposed replies above. Reply `go` to create the pending review, or point out any replies you want me to change."**

Also mention how many outdated threads will be auto-resolved:

**"<n> outdated threads will be auto-resolved immediately."**

### 8. Create Pending Review with Replies

Once confirmed, create a pending review and post all replies.

**Step 8a — Create the pending review:**

```bash
gh api graphql -f query='
mutation($prId: ID!) {
  addPullRequestReview(input: {pullRequestId: $prId}) {
    pullRequestReview {
      id
    }
  }
}' -f prId='{pullRequestNodeId}'
```

Save the returned `pullRequestReview.id` as `REVIEW_ID`.

**Step 8b — Reply to each review thread:**

For each review thread (not general PR comments) that has a reply (all three categories get replies), run:

```bash
gh api graphql -f query='
mutation($threadId: ID!, $reviewId: ID!, $body: String!) {
  addPullRequestReviewThreadReply(input: {
    pullRequestReviewThreadId: $threadId
    pullRequestReviewId: $reviewId
    body: $body
  }) {
    comment {
      id
    }
  }
}' -f threadId='{threadNodeId}' -f reviewId='{REVIEW_ID}' -f body='{replyText}'
```

All replies MUST be prefixed with the classification tag. For duplicate comments within a group (same issue, different location), reply with a short reference to the first comment's thread URL instead of repeating the full reply.

Reply templates:
- **VALID** (first occurrence): `VALID: I'll address this (#<n>).` — where `<n>` is a sequential counter across all VALID first-occurrence replies (1, 2, 3, ...)
- **VALID** (duplicate in group): `VALID: See <link to first comment's thread>` — use the GitHub discussion URL of the first comment in the group
- **NOOP**: `NOOP: Pre-existing behaviour, I'm happy to take charge of this, but if we want to fix these, we should do that as a separate PR. So we can extract and re-use the logic. Keeps this PR small and cohesive.`
- **NOOP** (duplicate in group): `NOOP: See <link to first comment's thread>`
- **INVALID**: `INVALID: <specific explanation>` (brief and clear, 1-2 sentences max, add an example if it's short and easy to read)
- **INVALID** (duplicate in group): `INVALID: See <link to first comment's thread>`

**DO NOT submit the review.** Leave it pending so only you can see it.

**Step 8c — Resolve outdated threads:**

For each unresolved thread where `isOutdated: true`, resolve it immediately:

```bash
gh api graphql -f query='
mutation($threadId: ID!) {
  resolveReviewThread(input: {threadId: $threadId}) {
    thread {
      isResolved
    }
  }
}' -f threadId='{threadNodeId}'
```

**Note:** This takes effect immediately (not pending). The thread will be marked as resolved and visible to everyone right away.

### 9. Summary

After posting all replies:

```
**Pending review created** with <total> replies:
- <n> VALID (will address)
- <n> NOOP (pre-existing, separate PR)
- <n> INVALID (explained)

**<n> outdated threads resolved** (immediate, visible to everyone).

The review is pending and only visible to you. Submit it from GitHub when ready.
```

Offer to store the results in `tmp/pr-comments-{pr-number}-round-{n}.md`. Use the round number sequential to the last existing one.

## Reply Guidelines

- **Be brief and respectful** in all replies
- **Invalid explanations** must be specific and factual — reference the actual code, not vague dismissals. Keep to 1-2 sentences.
- **Never be dismissive or rude** — even when a comment is wrong, explain clearly why
- When in doubt between VALID and PRE-EXISTING, check the codebase with Grep. If evidence is unclear, default to VALID.
- When in doubt between VALID and INVALID, default to VALID.

## Error Handling

If any step fails:
- Report the specific command that failed and its error output
- Stop and ask the user how to proceed
- DO NOT retry automatically
