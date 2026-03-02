# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal AI development workspace that serves as the single source of truth for:
- **Agent skills** shared across 10+ AI coding agents (Claude Code, Cursor, Cline, Copilot, etc.)
- **Kokoro TTS** local text-to-speech integration via Docker

## Architecture

### Symlink-based skill distribution

The repo is symlinked to global paths so all AI agents pick up the same skills:

```
~/dev/ai/agents  →  ~/.agents   (skill source of truth)
~/dev/ai/claude  →  ~/.claude   (Claude Code config + skill symlinks)
```

Skills flow: GitHub repos → `npx skills add` → `agents/skills/` (actual files) + `claude/skills/` (symlinks back to `~/.agents/skills/`).

### Directory layout

- **`agents/`** — Installed skills (actual code) + `.skill-lock.json` (v3, tracks sources/hashes/timestamps)
- **`claude/`** — Claude Code config (`settings.json`) + `skills/` symlinks pointing to agents skills
- **`kokoro/`** — Local TTS: Python hotkey listener, Swift implementation, Docker wrapper, ARM64 binary
- **`skills-lock.json`** — Global skill lock (v1 format, separate from agents lock)

### Skill format

Each skill is a directory containing `SKILL.md` with YAML frontmatter (`name`, `description`, `metadata`) and markdown instructions.

## Commands

### Skills management

```sh
npx skills find [query]      # Search for skills
npx skills add <pkg> -g -y   # Install skill globally, no prompt
npx skills check              # Check for updates
npx skills update             # Update all skills
npx skills init <name>        # Create new skill scaffold
```

Browse: https://skills.sh/

### Kokoro TTS

```sh
# Start the TTS server
docker run -p 8880:8880 ghcr.io/remsky/kokoro-fastapi-cpu:latest

# Run the hotkey listener (Ctrl+Space = read/stop, Ctrl+Shift+Q = quit)
pip install -r kokoro/requirements.txt
python3 kokoro/kokoro_hotkey.py

# Read a file aloud
python3 kokoro/kokoro_read_file.py <filepath>
```

API endpoint: `http://localhost:8880/v1/audio/speech`

## Conventions

- Commit messages use conventional format (`feat:`, `fix:`, etc.)
- No build system, linting, or test framework — this is a config/skills repo
- `.gitignore` prevents nested `.agent/`, `.agents/`, `.claude/`, `.trunk/` dirs from being committed (avoids recursive agent installs)
