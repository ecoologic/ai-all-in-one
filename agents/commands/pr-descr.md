---
description: Update PR description
---

# Update PR Tests Section

Update only a managed `## Tests` block in the existing pull request description.

Priority and overriding arguments: `$ARGUMENTS`

## Implementation Steps

### 1. Detect the current PR

Use the current branch's PR.

```bash
gh pr view --json id,number,url,body,baseRefName
```

If no PR is found for the current branch, report the error and stop.

Capture:
1. `id`
2. `number`
3. `url`
4. `body`
5. `baseRefName`

### 2. Identify changed test files

List changed files from the same comparison used later for test-case analysis:

```bash
git diff --name-only "origin/<baseRefName>...HEAD"
```

From that file list, keep only files that are clearly test/spec files. Use path and filename signals such as:
1. `__tests__/`
2. `/spec/`
3. `/tests/`
4. `*.test.*`
5. `*.spec.*`
6. request spec / API spec filenames

Ignore:
1. snapshots
2. fixtures
3. generated files
4. helper-only test utilities unless they contain actual test cases

If no changed test files remain, build a managed Tests block with:

```md
## Tests

- No new or changed test cases were detected in this branch.
```

### 3. Determine which test cases are new or changed

For each changed test file:
1. Diff the file against the PR base branch.
2. Read the current version of the file.
3. Identify only the test cases or spec examples that are new or materially changed in this branch.
4. Resolve each changed case to its full current nesting from the current file, not the old version.

Use git diff against the PR base branch:

```bash
git diff "origin/<baseRefName>...HEAD" -- "<path>"
```

Interpret "new or changed test cases" broadly enough to include:
1. new examples
2. renamed examples
3. changed expectations
4. changed contexts or nesting that materially change meaning

Do not mention deleted or previous wording. Output only the current test structure as it exists now.

### 4. Format the Tests section

Render the managed section in spec-documentation style using nested markdown bullets.

Example:

```md
## Tests

- `api/src/tests/endpoints/admin/get-data-partner-billing.test.ts`
  - PATCH /admin/data-partners/:dataPartnerId
    - when the request is valid
      - returns 200 with the updated data partner
- `admin/src/components/ChargebeeCustomerIdLink.test.tsx`
  - renders a link that opens in a new page
- `api/src/modles/user.test.ts`
  - User
    - create
      - when arguments are invalid
        - returns the descriptive error
```

Formatting rules:
1. Use only the current wording from the changed test files.
2. Preserve nesting and parent context when that context is needed to understand the example.
3. For the root element, prefer the most contextual top code element in this order:
   1. request or endpoint heading
   2. feature, page, component, or exported symbol heading
   3. file-derived fallback only when no better code element exists

Wrap the section with these exact sentinels:

```md
<!-- pr-descr:start -->
## Changes

* List only the changes a CEO would care about, _in a language they understand_
* In the format: "**Short Title**: _Before:_ xx; _After:_ yy"
* Focus on customer impact, business impact, risk, or launch readiness
* Keep it brief: 2-4 bullets max, if you have more, pick the ones with highest customer or business impact
* Skip refactors, internal tooling, tests, and technical details unless they materially affect revenue, cost, compliance, support load, performance, risk, or launch readiness

## Tests
...
<!-- pr-descr:end -->
```

### 5. Update only the managed block in the PR body

If the existing PR body already contains:
1. `<!-- pr-descr:start -->`
2. `<!-- pr-descr:end -->`

Replace only the content between those markers, inclusive.

Otherwise:
1. Insert the managed Tests block immediately above the PR's notes section when a clear notes heading exists near the end of the body.
2. If no notes anchor exists, append the managed Tests block to the end of the body.
3. Leave the rest of the body unchanged.
4. Preserve spacing cleanly with a single blank line between sections.

Do not rewrite, reorder, or remove any content outside the managed block.

### 6. Write the updated PR body safely

Write the full updated body to a temporary file, then update the PR description from that file.

Use `python3` or another non-interactive script to replace or prepend the sentinel block safely.

Example shape:

```bash
gh pr edit <number> --body-file "<temp-file>"
```

Do not pass large multiline content inline on the command line.

### 7. Mark changed test files as viewed

After the PR body update succeeds, mark every changed test file from step 2 as viewed on the current PR.

If no changed test files were detected, skip this step.

Use the PR node id from step 1 with GitHub GraphQL:

```bash
gh api graphql -f query='
mutation($pullRequestId: ID!, $path: String!) {
  markFileAsViewed(input: {pullRequestId: $pullRequestId, path: $path}) {
    clientMutationId
  }
}' -f pullRequestId='<id>' -f path='<path>'
```

Requirements:
1. Mark only the changed test files used by this command.
2. Run the mutation once per file path.
3. Treat already-viewed files as non-fatal only if GitHub accepts the request without error.
4. If any `markFileAsViewed` call fails, report the failing command and stop.

### 8. Report the result

After updating the PR description and marking test files as viewed, report:
1. PR number
2. PR URL
3. whether the Tests block was inserted or replaced
4. how many changed test files were used
5. how many new or changed test cases were summarized
6. how many test files were marked as viewed

## Important Notes

1. NEVER create a new PR.
2. NEVER push commits or modify repository files as part of this command.
3. NEVER overwrite handwritten notes, bottom sections, or Mermaid diagrams outside the managed block.
4. DO NOT describe old test names or deleted cases.
5. DO NOT include a diagrams section in this command.
6. If test intent is ambiguous, stop and ask instead of inventing structure.

## Error Handling

If any step fails:
1. Report the exact command that failed.
2. Report the relevant error output.
3. Explain whether failure happened during PR detection, test discovery, diff analysis, block replacement, `gh pr edit`, or `markFileAsViewed`.
4. Stop and ask how to proceed.
5. DO NOT retry automatically.
