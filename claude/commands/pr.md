---
description: Push code, open/update a draft PR with user-perspective description, sequence diagram, and class diagram
---

# Draft PR

Push the current branch and open (or update) a GitHub draft PR. Generate a succinct title, a clarifying paragraph, and Mermaid diagrams — all based on the actual code changes.

**CRITICAL**: Diagram only what EXISTS in the diff. Do not diagram aspirational designs, future plans, or unchanged code. Every element in the description and diagrams must correspond to something in the actual changes. DO NOT hide what's missing, EXACTLY THE CONTRARY, be transparent and informative about the work done.

## Implementation Steps

### 1. Gather Context

Run these commands to understand the full scope of changes:

```bash
git status
git log --oneline -10
git rev-parse --abbrev-ref HEAD
```

Determine the base branch:

```bash
git log --oneline main..HEAD
```

If `main` does not exist, try `master`. Use whichever exists as `BASE_BRANCH`.

Run a full diff against the base branch — this is the source of truth for the PR:

```bash
git diff BASE_BRANCH...HEAD
```

Also check for uncommitted changes:

```bash
git diff HEAD
```

Ignore uncommitted changes.

### 2. Push the Branch

Push the current branch to origin, setting upstream if needed:

```bash
git push -u origin HEAD
```

If push fails, report the error and stop.

### 3. Check for Existing PR

Check if a PR already exists for this branch:

```bash
gh pr view --json number,title,url,isDraft 2>/dev/null
```

If a PR exists:
- Update its title and body (step 4-6 below)
- Use `gh pr edit` to apply changes

If no PR exists:
- Create a new draft PR using `gh pr create --draft`

### 4. Write the PR Title

Analyze ALL commits from `BASE_BRANCH..HEAD` plus any uncommitted changes.

Write a succinct title (under 70 characters) that describes what changed **from the user's perspective**:
- Focus on the user-visible outcome, not implementation details
- Use imperative mood ("Add search filtering" not "Added search filtering code")
- Example: "Add keyboard shortcuts for navigation" (NOT "Refactor KeyHandler class and add event listeners")

### 5. Write the PR Description Paragraph

Write a single paragraph (3-5 sentences max) that clarifies the title **from the user's perspective**:
- DO NOT repeat the title — add context the title couldn't convey
- Explain WHY this matters to the user, not HOW it was implemented (yet)
- Mention any notable behavior changes, edge cases handled, or limitations
- Keep it non-redundant: every sentence must add information not already in the title

### 6. Generate Mermaid Diagrams

Analyze the actual code diff (`git diff BASE_BRANCH...HEAD`) to create two diagrams.

#### Sequence Diagram

Create a Mermaid sequence diagram showing the runtime flow of the changed code:
- Participants are the actual modules/classes/functions that were modified or added
- Messages show the actual calls/data flow introduced or changed
- Keep it focused: only interactions that are new or modified
- Use `autonumber` for clarity

Example structure:
```
sequenceDiagram
    autonumber
    participant A as ModuleName
    participant B as OtherModule
    A->>B: methodCall()
    B-->>A: response
```

#### Class Diagram

Create a Mermaid class diagram showing the structural changes:
- Only include classes/modules/types that were added or modified in the diff
- Show actual methods and properties that changed (use `+` for public, `-` for private)
- Show relationships (inheritance, composition, dependency) only where they were added or changed
- For non-OOP code (functions, config files), use classes to represent modules/files with their exported functions

Example structure:
```
classDiagram
    class ModuleName {
        +newMethod()
        +modifiedMethod()
        -privateHelper()
    }
    ModuleName --> DependencyName
```

If the changes are trivial (e.g., only config/docs) and a diagram would be meaningless, skip that diagram and note why.

### 7. Create or Update the PR

Compose the full PR body:

```markdown
[Single clarifying paragraph from step 5]

## Sequence Diagram

```mermaid
[sequence diagram from step 6]
```

## Class Diagram

```mermaid
[class diagram from step 6]
```
```

If **creating** a new PR:

```bash
gh pr create --draft --title "TITLE" --body "BODY"
```

If **updating** an existing PR:

```bash
gh pr edit --title "TITLE" --body "BODY"
```

Use a HEREDOC for the body to preserve formatting:

```bash
gh pr create --draft --title "the title" --body "$(cat <<'EOF'
body content here
EOF
)"
```

### 8. Report Results

Output:
- PR URL
- Title used
- Whether PR was created or updated
- A note that it is a draft PR

## Important Notes

- **ALL diagrams must reflect the actual diff** — not aspirational or future code
- **Title and description are user-perspective** — not developer-perspective
- **Description must not repeat the title** — every sentence adds new info
- **NEVER force-push** — use regular `git push`
- **DO NOT commit changes automatically** — if uncommitted changes exist, ask first
- If the branch has no commits beyond the base, report "nothing to PR" and stop

## Error Handling

If any step fails:
- Report the specific command that failed and its error output
- Stop and ask the user how to proceed
- DO NOT retry automatically
