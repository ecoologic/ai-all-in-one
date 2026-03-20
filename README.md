# AI all in one

This project is just to setup AI to be used in other projects. It works based on symlinks to root AI folders, so it can be used in all projects. Mainly covering Cursor and Claude.

All in one folder. Then linked to global scope with:

```sh
# Make sure these folders don't already exist, or you might get double-nesting
ln -s ~/dev/ai/agents ~/.agents
ln -s ~/dev/ai/claude ~/.claude
ln -s ~/dev/ai/cursor ~/.cursor


ln -s ~/dev/ai/agents/rules/GLOBAL.md ~/.claude/CLAUDE.md
# Cursor .mdc symlinks don't work reliably — use Cursor Settings > User Rules if you have a problem
# Cursor is a repo itself, so we need to link the subfolders too
ln -s ~/dev/ai/agents/rules ~/.cursor/rules
ln -s ~/dev/ai/agents/rules/GLOBAL.md ~/.cursor/rules/GLOBAL.mdc
```

## Global scope files

Symlinked to `~` so all AI agents pick them up:

- `agents/` → `~/.agents` — global scope skill code lives here
  - `skills/` — installed skill directories (each contains a `SKILL.md`)
  - `.skill-lock.json` — tracks installed skills with sources, hashes, timestamps (v3)

- `claude/` → `~/.claude` — Claude Code user-level config
  - `skills/` — symlinks to `~/.agents/skills/`, makes skills available to Claude Code
  - `settings.json` — Claude Code user settings

- `cursor/` → `~/.cursor` — Cursor user-level config (whole directory symlinked)
  - `commands/` — global scope slash commands, each `.md` file becomes `/filename` in chat
  - `rules/` — Cursor rule files; documented cross-project global scope rules are User Rules configured in Settings
  - `skills-cursor/` — Cursor-specific skills (separate from `~/.agents/skills/`)
  - NOTE: Cursor is its own git repo

## Local scope files

Note this repo has skills and settings both global, BUT ALSO, has its own local AI customisations (eg: `find-skill` is only available in this repo).

Only active in this repo:

- `.agents/skills/` — repo-local skills (not symlinked globally)
- `skills-lock.json` — tracks repo-local skills in `.agents/skills/` (v3 format)
- `.claude/` — project-level Claude Code config (gitignored)
  - `skills/` — symlinks to skills available only in this repo
- `tts/` — Kokoro TTS integration: hotkey listener, Docker wrapper, binary
- `notes.md` — development TODOs and notes
- `CLAUDE.md` — instructions for Claude Code when working in this repo
