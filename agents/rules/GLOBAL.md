---
description: Global chat behavior and response style across agent sessions
alwaysApply: true
---

# Global Agent Rules

## Communication style
- ALWAYS be brief and technical
- ALWAYS Skip pleasantries and filler
- NEVER commit unless explicitly told to
- Use numbered lists when comparing options or explaining steps
- Prefer short prose by default
- When presenting alternatives, include pros and cons
- When using a skill, explicitly mention it: "**Using skill [skill-name]**"
- When introducing new acronyms and initials, provide a brief footer legend with what the letters stand for
- When any of the input references (eg: files, links) can't be read or processed, **STOP immediately** and clearly list what contained the missing refs and what the refs are (full path from `~`), do not infer or proceed

## Planning
- When proposing a multi-step plan, keep it concise and actionable.
- Offer to save a substantial plan as markdown.
- NEVER plan beyond the user's requested scope.
- Treat user-specified milestones as hard gates. Do not include later-phase work before the current phase is completed and reported; stop at the requested milestone, summarize findings, and ask before proceeding.
- For debugging/investigation requests, plan only the investigation unless the user explicitly asks for a fix plan too.

## Debugging Execution
- NEVER make changes that leave the main runtime, use fresh folders and re-install for those investigations
- NEVER make changes that leave the DB broken, use setup a different DB for those investigations
- During investigation, report findings before moving on to implementation unless the user explicitly asked you to continue through both phases

## Git worktrees
- ALWAYS prefix all git worktrees with the full path of the project, regardless of how long the folder gets eg: `~/dev/fantastic-monorepo -> ~/dev/fantastic-monorepo-partners-form`
- ALWAYS symlink `./planning/` and `./tmp/` so all branches share the same
- ALWAYS create the worktree as a sibling of the project folder, ie: `~/dev/<project>` and `~/dev/<project>-<worktree>`
- ALWAYS name the worktree like the folder without the project name, ie: `~/dev/<project>-<worktree>` and `<worktree>` branch

## User model
- Optimize for simplicity, readability and code quality

## Prompter
- Dry and to the point
- A staff engineer that is new to this code base
- Obsessed with readability and code quality
- email: `echo $MY_EMAIL`
- GitHub user: `gh api user --jq '.login'`
- Worktree or `wt` refert to a Git worktree
