# AI process

## Agent rules organization

```
sup-brainstorm -> brainstorming
sup-plan -> writing-plans
sup-code -> executing-plans
sup-verify -> verification-before-completion
sup-review -> requesting-code-review
```

- Claude with plugins
  - Planning
    - `brainstorming`
    - `writing-plans`
  - Code
    - `executing-plans`
    - `verification-before-completion`
  - Cleanup
    - `requesting-code-review`

- Cursor
  - Edits
  - Debug

- QA `TODO!!`

### 

## Claude plugins

1. `brainstorming` — before any creative/feature work
2. `writing-plans` — after brainstorm, before code
3. `using-git-worktrees` — before starting implementation
4. `test-driven-development` — before writing implementation code
5. `executing-plans` — agent picks up a written plan in a new session
6. `systematic-debugging` — when something breaks
7. `verification-before-completion` — before claiming done
8. `requesting-code-review` — after verification passes
9. `finishing-a-development-branch` — merge/PR/cleanup
10. `receiving-code-review` — when feedback comes back
11. `writing-skills` — to capture reusable workflows

Auto-invoked by the agent (not user-called):
- `using-superpowers` — session start
- `dispatching-parallel-agents` — agent decides to parallelize
- `subagent-driven-development` — agent decides to use subagents for plan execution

## Claude improvers


  ┌──────────┬─────────────────────────────────────────────────────────────┬───────────────────────────────────────────────────────────────┐
  │          │                      revise-claude-md                       │                      claude-md-improver                       │
  ├──────────┼─────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ Author   │ claude-plugins-official (Anthropic marketplace)             │ claude-plugins-official (same plugin)                         │
  ├──────────┼─────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ Trigger  │ End of a work session                                       │ On-demand audit                                               │
  ├──────────┼─────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ Input    │ Current conversation context                                │ The CLAUDE.md files themselves                                │
  ├──────────┼─────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ Approach │ Reflect on what was learned this session, propose additions │ Score files against a rubric, find gaps regardless of session │
  ├──────────┼─────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ Output   │ Targeted diff additions from session learnings              │ Quality report (A–F grade) + improvement diffs                │
  ├──────────┼─────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ Scope    │ Narrow — only what came up in this session                  │ Broad — full audit of all CLAUDE.md files in repo             │
  ├──────────┼─────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ Phases   │ 5: Reflect → Find → Draft → Show → Apply                    │ 5: Discover → Assess → Report → Update → Apply                │
  ├──────────┼─────────────────────────────────────────────────────────────┼───────────────────────────────────────────────────────────────┤
  │ Best for │ Incremental maintenance after doing real work               │ Periodic health check / initial setup                         │
  └──────────┴─────────────────────────────────────────────────────────────┴───────────────────────────────────────────────────────────────┘
