---
description: Triage unresolved PR review comments, verify them, and present an ordered action list
---

# Triage PR Review Comments

Fetch unresolved PR review comments from reviewers, verify whether each comment is valid, dedupe repeated feedback, and present the results in code order as an action list for the user.

Argument: $ARGUMENTS

## Implementation Steps

### 1. Detect PR

If `$ARGUMENTS` is a number, use it as the PR number. Otherwise, detect from the current branch:

```bash
gh pr view --json number,url
```

If no PR is found, report the error and stop.

### 2. Fetch Review Comments (GraphQL)

Use GraphQL to fetch the PR author, file order, and unresolved review threads, not outdated, including each review comment URL. Run:

```bash
gh api graphql -f query='
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      title
      url
      author { login }
      files(first: 100) {
        nodes {
          path
        }
      }
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          path
          line
          startLine
          diffSide
          comments(first: 10) {
            nodes {
              id
              url
              body
              author { login }
              createdAt
            }
          }
        }
      }
    }
  }
}' -f owner='{owner}' -f repo='{repo}' -F pr={number}
```

Replace `{owner}`, `{repo}`, and `{number}` with values from `gh repo view --json owner,name` and the PR number from step 1.

Only process threads where `isResolved: false`.

**Important:** the PR author is `pullRequest.author.login`, not the current authenticated GitHub user.

Ignore comments written by the PR author. If a thread contains both reviewer comments and PR author replies, only keep the reviewer comments for presentation, but read the PR author's replies as rebuttal context. If a thread has no reviewer comments left after filtering, drop it entirely.

Do not create or post replies in GitHub. Do not draft or post approval text unless the user explicitly asks in a separate follow-up. This command is analysis and presentation only.

When building links for the final output, convert it to the Changes tab form: `.../pull/<n>/changes#r<id>`.

### 3. Expand the Review Set

For each remaining reviewer comment:

1. Read the referenced file and the surrounding code near `line` or `startLine`.
2. If needed, inspect nearby symbols, related files, or tests.
3. If the comment makes a broader claim like "this pattern is wrong everywhere" or "this logic is duplicated", search the repo to verify that claim before deciding.
4. Keep notes on what the comment is asking for, whether it is actually correct, and roughly how much work it would take to address within this PR.

Be skeptical but fair. Verify against the code before deciding.

### 4. Classify Each Comment

#### Skills to Load for Validation and Follow-Up Work

Load the relevant skills below when they help validate whether a comment is actually correct. If valid comments would likely require code changes in a later follow-up, mention the relevant skills in the closing recommendation so the next step is clear, but do not start fixing anything in this command.

- If a later follow-up will involve implementation work, load `ecoologic-code`.
- If that later follow-up would touch `.ts`, `.tsx`, `.js`, or `.jsx` files, also load `typescript-best-practices`.
- If that later follow-up would touch React components or hooks, also load `react-best-practices`.
- If the valid comments are about UI, UX, layout, accessibility, or interaction design, also load `ux-laws` for that later follow-up.
- If the valid comments are specifically a UI review, design quality, or accessibility audit, also load `web-design-guidelines` for that later follow-up.

#### Process

Each comment must end up in exactly one category:

- `VALID[quick]`: the reviewer is correct and the fix should be small, local, and low-risk
- `VALID[mid]`: the reviewer is correct and the fix needs a moderate code change, touches a couple of call sites, or needs careful adjustment
- `VALID[long]`: the reviewer is correct but the fix is broader, cross-cutting, or requires meaningful refactoring / follow-up work
- `INVALID`: the reviewer is mistaken, outdated, based on a misunderstanding, or is not actually asking for an actionable change

When uncertain between `VALID[...]` and `INVALID`, default to `VALID[...]` with the best effort estimate.

If the PR author already replied explaining that the reviewer comment is wholly or partly based on a misunderstanding, stale assumption, or incorrect reading of the code, bias the classification toward `INVALID`. Treat the author's reply as evidence to verify against the code, not as automatic proof. When this is the deciding factor, explicitly include `author reviewed` in the `INVALID` explanation.

### 5. Dedupe Repeated Feedback

Group comments only when they are effectively the same issue and would receive the same reasoning and same fix. Use a high bar for dedupe.

Examples that should usually dedupe:

- The same missing null check called out in several files
- The same naming issue repeated across multiple call sites
- The same architectural concern repeated on multiple hunks

Examples that should usually stay separate:

- Similar wording but materially different fixes
- Same theme, different root cause
- Same reviewer concern, but one instance is valid and another is invalid

For each deduped issue:

- Keep the first comment as the canonical entry
- Record every display number that belongs to that repeated issue
- Preserve only the first comment's text in the final output
- Use the canonical comment's GitHub review comment URL to derive a Changes tab link as the display link target
- Mention all matching numbers together, like `2, 5, 8.`

### 6. Order Issues by Code Position

Present issues in the order they appear in the PR diff:

1. Use `pullRequest.files.nodes[].path` to determine file order.
2. Within a file, sort by the earliest available line: `startLine`, else `line`, else push to the end of that file.
3. For deduped issues, use the canonical comment's position.

### 7. Present Results to the User

Start with:

```text
## PR #<number>: <title>
<url>
```

Then list each deduped issue in order using exactly this shape:

```text
<n>[, <n2>, <n3>]. @<reviewer login>
[path/to/file.ts:<line>](<canonical-review-comment-changes-url>)
> <comment text truncated to one paragraph>

VALID[quick|mid|long]
<brief paragraph explaining why this is valid and what makes it quick, mid, or long>
```

Or:

```text
<n>[, <n2>, <n3>]. @<reviewer login>
[path/to/file.ts:<line>](<canonical-review-comment-changes-url>)
> <comment text truncated to one paragraph>

INVALID
<brief paragraph explaining why the comment is not correct or not actionable>
```

Presentation rules:

- Number every raw reviewer comment first, in code order, before deduping. If comments 4 and 7 are duplicates of comment 2, the canonical entry should render as `2, 4, 7.`
- Render `path:line` as a markdown link to the canonical PR review comment's Changes tab URL, for example `https://github.com/owner/repo/pull/326/changes#r2929596414`.
- Truncate the quoted reviewer text to a single paragraph. Remove extra blank lines and shorten if needed, but preserve the substance.
- Do not include planned GitHub reply text.
- Do not include storage paths or persistence details in the main triage list itself.
- Do not include general PR comments outside review threads.
- Keep explanations concise but specific to the code.

### 8. Close with a Clear Next Step

After the numbered list, close with:

1. Make it explicit that this command only triages comments and does not start fixes, post GitHub replies, or push anything.
2. Offer to address the valid comments in order only if the user explicitly asks in a follow-up message.
3. If any valid comment would require code changes in that later follow-up, mention the relevant skills loaded from the section above.
4. Offer to store the triage result in `./tmp/pr-<number>.md` for a clean follow-up agent, and make it clear that a simple reply of `write` should trigger that storage.
5. If all valid comments have already been addressed, say the branch may be ready to push, but do not push anything as part of this command, until told, and if so, also resolve all outdated comments.

Example closing line:

```text
This command only triages the unresolved review comments. It does not start fixes, post GitHub replies, or push the branch.

If you want, I can address the valid items in order in a follow-up message, starting with #<first-valid-comment-number>.

Loaded relevant skills: `ecoologic-code`, `typescript-best-practices`

If all valid items are already addressed, the branch may be ready to push.

Reply `write` if you want me to store this triage as `./tmp/pr-<number>.md`
```

The prompter will use the comment numbers to address the various comments.

### 9. Optional Handoff File

If the user replies `write`, store the triage result in `./tmp/pr-<number>.md`.

Requirements for that file:

- Make it self-contained so a fresh agent can understand the context with no prior chat history.
- Start by stating that this document is the current PR comment triage and that the next step is to address the valid PR comments by their numbers.
- Include the PR number, title, and URL.
- Include the same numbered deduped issue list that was shown to the user, preserving numbering exactly.
- Preserve each issue's reviewer login, linked `path:line`, comment excerpt, and `VALID[quick|mid|long]` or `INVALID` reasoning.
- Preserve duplicate-number groupings such as `2, 5, 8.`
- Preserve important context such as `author reviewed` when it was part of the reasoning.
- Include the relevant loaded skills if code changes are expected.
- Explicitly instruct the next agent to use those skills while validating and addressing the valid comments.
- End with a short instruction that the next agent should address the valid comments in numeric order unless told otherwise.

When writing this file:

- Reuse the already-produced triage output rather than regenerating it from scratch.
- Ensure `./tmp` exists first.
- After writing, tell the user the exact file path that was created.

## Reply Guidelines

- Validate comments against the actual code before deciding.
- Do not invent certainty. If the code is ambiguous, say why, then choose the most defensible classification.
- Use the response you already produced
- Treat repeated comments as one issue only when they genuinely share the same fix and reasoning.
- When in doubt between `VALID[...]` and `INVALID`, default to `VALID[...]`.
- Do not start fixing files, posting GitHub comments, or pushing the branch as part of this command.

## Error Handling

If any step fails:
- Report the specific command that failed and its error output
- Stop and ask the user how to proceed
- DO NOT retry automatically
