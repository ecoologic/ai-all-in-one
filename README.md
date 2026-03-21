# AI all in one

This project is just to setup AI to be used in other projects. It works based on symlinks to root AI folders, so it can be used in all projects. Mainly covering Cursor and Claude.

All in one folder. Then linked to global scope with:

```sh
# Make sure these folders don't already exist, or you might get double-nesting
ln -s ~/dev/ai/agents ~/.agents
ln -s ~/dev/ai/claude ~/.claude
ln -s ~/dev/ai/cursor ~/.cursor

ln -s ~/dev/ai/agents/rules/GLOBAL.md ~/.claude/CLAUDE.md
```

The remaining internal symlinks are already checked into the repos:
- `claude/skills/` → `~/.agents/skills/` (folder symlink, all skills auto-available)
- `cursor/skills/` → `~/.agents/skills/` (folder symlink, all skills auto-available)
- `cursor/rules/` → `agents/rules/` (folder symlink)
- `agents/rules/GLOBAL.mdc` → `GLOBAL.md` (Cursor needs `.mdc` extension)

## Global scope files

Symlinked to `~` so all AI agents pick them up:

- `agents/` → `~/.agents` — global scope skill code lives here
  - `skills/` — installed skill directories (each contains a `SKILL.md`)
  - `.skill-lock.json` — tracks installed skills with sources, hashes, timestamps (v3)

- `claude/` → `~/.claude` — Claude Code user-level config
  - `skills/` → `~/.agents/skills/` — folder symlink, all shared skills auto-available
  - `commands/` — slash commands, each `.md` file becomes `/filename`
  - `settings.json` — Claude Code user settings

- `cursor/` → `~/.cursor` — Cursor user-level config (whole directory symlinked)
  - `commands/` — slash commands, each `.md` file becomes `/filename`
  - `rules/` → `agents/rules/` — folder symlink, shared rules auto-available
  - `skills/` → `~/.agents/skills/` — folder symlink, all shared skills auto-available
  - `skills-cursor/` — Cursor-only skills (in addition to shared skills)
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
