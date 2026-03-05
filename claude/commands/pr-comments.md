---
description: Fetch and display PR review comments grouped by similarity and ordered by importance
---

# Get PR Review Comments

Fetch all unresolved review comments for a PR, group them by similarity, order by importance, and present a numbered list. **Read-only — do not apply any fixes.**

Argument: $ARGUMENTS

## Implementation Steps

### 1. Detect PR

If `$ARGUMENTS` is a number, use it as the PR number. Otherwise, detect from the current branch:

```bash
gh pr view --json number,url
```

If no PR is found, report the error and stop.

### 2. Fetch Review Comments (GraphQL)

Use GraphQL to get unresolved review threads with full context. Run:

```bash
gh api graphql -f query='
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      title
      url
      reviewThreads(first: 100) {
        nodes {
          isResolved
          isOutdated
          path
          line
          startLine
          diffSide
          comments(first: 10) {
            nodes {
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

### 3. Group Comments by Similarity

Analyze all unresolved comments and group them semantically:

- **Same feedback repeated across files** (e.g., multiple "add types", "rename this", "missing error handling")
- **Related concerns** (e.g., several comments about the same architectural issue)
- **Standalone comments** get their own group

Each group gets a short label describing the theme (e.g., "Type safety", "Naming", "Error handling", "Missing tests").

### 4. Order Groups by Importance

Sort groups using this priority (highest first):

1. **Bugs / logic errors** — incorrect behavior, race conditions, security issues
2. **Missing error handling** — unhandled edge cases, missing validation
3. **Missing tests** — untested code paths, missing test coverage
4. **API / interface issues** — wrong return types, bad abstractions, breaking changes
5. **Naming / readability** — unclear names, confusing code structure
6. **Style / nits** — formatting, minor preferences, cosmetic issues

### 5. Present Results

**NOTE**: Not every comment is a direct request to change some code, it might be a praise or a clarification, those would have the least priority.

Output the results in this exact format:

```
## PR #<number>: <title>
<url>

### 1. [GROUP: <Label>] (<N> comments)

- `path/to/file.ts:42`
  `const foo = bar()` ← (the code line from the diff hunk, trimmed)
  > Comment text here — @author

- `path/to/other.ts:15`
  `function doThing() {`
  > Another comment in the same group — @author

### 2. [GROUP: <Label>] (<N> comments)

...
```

For **general PR comments** (not attached to a specific line), list them at the end under:

```
### General Comments

- > Comment body — @author
```

### 6. Summary

After the full list, add a one-line summary:

```
**Summary**: <total> unresolved comments in <group-count> groups. Top priority: <highest group label>.
```

### 7. Stop

**DO NOT apply any fixes.** Present the list and wait for user input. Offer to store the result in `tmp/pr-comments-{pr-number}.md`

## Error Handling

If any step fails:
- Report the specific command that failed and its error output
- Stop and ask the user how to proceed
- DO NOT retry automatically
