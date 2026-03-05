# Plan commands

I want to create a series of commands that work together

* Plan commands
  * `/epic /personas /architecture /story /task /review /pr`
* Review
  * `/review-unhappy-path /review-security /review-bugs /review-qa`
* PR addressing comments
  * `/pr-comments`

We have already worked on some of these, but each new command might require to update one or more of the others.

And I appreciate your input and help to make them the most efficient to work with you.

But we will create them sequentially, one at a time, over the course of many sessions. Note this file has a section just for your thoughts, that I'd be happy for you to keep updated with your notes and suggestions for work to come. Feel free to edit "below the line".

Before we implement a command, write your comments "below the line".

I think we might benefit from a separate file to group these commands as project. Is it possible to nest sub-folders in the command directory? what would you suggest here?

## My suggestion

* Ensure we use all the Claude template keywords and tags appropriately
* Make sure we explicitly state to use (and list) the relevant skills
* Make sure each command is aware of the previous and next one

## AI thoughts

You can take notes for your own context here below...

---

### Subdirectory nesting: NO

Claude Code discovers commands as flat `.md` files in `commands/`. Nested folders are silently ignored. Grouping must use naming conventions (`review-*.md`, `pr-*.md`).

### Pipeline awareness pattern

Each command gets a `## Pipeline` section with ASCII art showing the full pipeline, a `^current` marker, and an input/output table (receives from / produces / feeds into). This is lightweight and keeps commands self-documenting.

### Suggested implementation sequence

Start with updating `/epic` (smallest change, validates the boilerplate pattern), then create `/personas` (simple new command), then `/architecture` (complex), etc. One per session. After each, run `/nope` to audit.

### Key design decisions to confirm with user

1. Review commands: conversation-only output vs file output
2. Review pipeline: sequential vs a la carte
3. `/task` commit behavior: ask vs auto-commit

### Notes for future sessions

- `/architecture` is the most complex new command — it combines `explore`, `ecoologic-code`, and `mermaid-diagrams` skills. Design it carefully.
- `/task` is the only planning-pipeline command that writes code. It needs strong guardrails against scope creep.
- `/pr-comments` needs GitHub API calls (`gh api repos/{owner}/{repo}/pulls/{number}/comments`) — test this pattern.
- Consider whether `simplify` skill should be invoked in `/review` or `/task` post-implementation.
- All review commands share the same diff-gathering preamble — could extract to a shared pattern doc or just keep it duplicated (YAGNI says duplicate for now).
