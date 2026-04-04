# AI process

## Superpowers

1. `brainstorming` — before any creative/feature work
2. `writing-plans` — after brainstorm, before code
3. `using-git-worktrees` — before starting implementation
4. `test-driven-development` — before writing implementation code
5. `systematic-debugging` — when something breaks
6. `executing-plans` — agent picks up a written plan in a new session
7. `verification-before-completion` — before claiming done
8. `requesting-code-review` — after verification passes
9. `receiving-code-review` — when feedback comes back
10. `finishing-a-development-branch` — merge/PR/cleanup
11. `writing-skills` — to capture reusable workflows

Auto-invoked by the agent (not user-called):
- `using-superpowers` — session start
- `dispatching-parallel-agents` — agent decides to parallelize
- `subagent-driven-development` — agent decides to use subagents for plan execution

## Agile

```sh
/using-superpowers
/rtd

/a-epic
/a-story

/superpowers:brainstorm
/superpowers:write-plan
/superpowers:execute-plan

/simplify
/local-review
plugin:greptile:greptile
cursor_review # CLI
```
