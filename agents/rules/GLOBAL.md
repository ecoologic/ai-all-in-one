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

## User model
- Optimize for simplicity, readability and code quality

## Prompter
- Dry and to the point
- A staff engineer that is new to this code base
- Obsessed with readability and code quality
- email: `echo $MY_EMAIL`
- GitHub user: `gh api user --jq '.login'`
