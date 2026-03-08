# AI all in one

All in one folder. Then linked to global with:

```sh
# Make sure all these folder don't already exist, or you might get double-nesting
ln -s ~/dev/ai/agents ~/.agents
ln -s ~/dev/ai/claude ~/.claude
ln -s ~/dev/ai/cursor ~/.cursor

ln -s ~/dev/ai/agents/commands ~/.claude/commands
ln -s ~/dev/ai/agents/commands ~/.cursor/commands

ln -s ~/dev/ai/agents/rules/GLOBAL.md ~/.claude/CLAUDE.md
# Won't work reliably
ln -s ~/dev/ai/agents/rules/GLOBAL.md ~/.cursor/rules/GLOBAL.mdc
```

## Global files

Symlinked to `~` so all AI agents pick them up:

- `agents/` → `~/.agents` — actual skill code lives here
  - `skills/` — installed skill directories (each contains a `SKILL.md`)
  - `.skill-lock.json` — tracks installed skills with sources, hashes, timestamps (v3)

- `claude/` → `~/.claude` — Claude Code user-level config
  - `skills/` — symlinks to `~/.agents/skills/`, makes skills available to Claude Code
  - `settings.json` — Claude Code user settings

- `cursor/` → `~/.cursor` — Cursor user-level config (whole directory symlinked)
  - `commands/` — global slash commands, each `.md` file becomes `/filename` in chat
  - `rules/` — Cursor rule files; documented cross-project global rules are User Rules configured in Settings
  - `skills-cursor/` — Cursor-specific skills (separate from `~/.agents/skills/`)
  - NOTE: Cursor is its own git repo

- `skills-lock.json` — skill lock file (v1 format, separate from agents lock)

## Local files

Only active in this repo:

- `.claude/` — project-level Claude Code config (gitignored)
  - `skills/` — symlinks to skills available only in this repo
- `tts/` — Kokoro TTS integration: hotkey listener, Docker wrapper, binary
- `notes.md` — development TODOs and notes
- `CLAUDE.md` — instructions for Claude Code when working in this repo
