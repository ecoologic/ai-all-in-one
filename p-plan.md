# Command Pipeline

## Flow

```
p-epic -> p-personas -> p-architecture -> p-story(N) -> p-task(N×M) -> p-review -> p-review-*(K) -> p-review-issue(K) -> p-pr -> p-pr-comments(C)
```

## Cardinality

| Stage              | Input                   | Output                           | 1:N                    |
| ------------------ | ----------------------- | -------------------------------- | ---------------------- |
| `p-epic`           | Epic description        | `~/dev/docs/<project>/<slug>/stories.md`         | 1 → N stories          |
| `p-personas`       | Stories file            | `~/dev/docs/<project>/<slug>/personas.md`        | N stories → P personas |
| `p-architecture`   | Stories + personas      | `~/dev/docs/<project>/<slug>/architecture.md`    | 1 per epic             |
| `p-story N`        | Stories file + story #  | `~/dev/docs/<project>/<slug>/story-<N>-tasks.md` | 1 → M tasks            |
| `p-task N`         | Tasks file + task #     | Source code                      | 1 → code               |
| `p-review`         | Branch diff             | `~/dev/docs/<project>/<slug>/review.md`          | 1 → K findings         |
| `p-review-*`       | Branch diff             | `~/dev/docs/<project>/<slug>/review-<type>.md`   | 1 → K findings         |
| `p-review-issue N` | Review file + finding # | Code fix                         | 1 → 1 fix              |
| `p-pr`             | Branch                  | GitHub draft PR                  | 1 → 1                  |
| `p-pr-comments N`  | PR comment #            | Code fix + reply                 | 1 → 1 fix              |

## Docs path

```
~/dev/docs/<project>/<epic-slug>/
```

Resolution order for `<project>`:
1. If `~/dev/docs/settings.json` has a key matching the git root basename → use its value
2. Else → `basename $(git rev-parse --show-toplevel)`

Example `~/dev/docs/settings.json`:
```json
{
  "projects": {
    "pineapple-monorepo": {
      "name": "pineapple",
      "epic": "user-auth"
    }
  }
}
```

- `name` — overrides the `<project>` folder name (optional, defaults to git root basename)
- `epic` — default `<epic-slug>` when no argument is provided (optional)

Running from `~/dev/pineapple-monorepo` with no args → `~/dev/docs/pineapple/user-auth/`

## Artifact chain

```
~/dev/docs/<project>/<epic-slug>/
├── stories.md              ← p-epic
├── personas.md             ← p-personas
├── architecture.md         ← p-architecture
├── story-1-tasks.md        ← p-story 1
├── story-2-tasks.md        ← p-story 2
├── review.md               ← p-review
├── review-security.md      ← p-review-security
├── review-bugs.md          ← p-review-bugs
├── review-unhappy-path.md  ← p-review-unhappy-path
└── review-qa.md            ← p-review-qa
```

## Design decisions

| Decision          | Choice                                       |
| ----------------- | -------------------------------------------- |
| Prefix            | All pipeline commands: `p-`                  |
| Lean commands     | Minimal prose, direct instructions, no bloat |
| No subdirectories | Claude Code doesn't support nested commands  |
| Review output     | Persisted to files with numbered findings    |
| Review flow       | Sequential, each also works standalone       |
| Commit behavior   | Commands never commit — user controls        |

## Shared patterns (all `p-*` commands)

1. Frontmatter: `description`, `argument-hint`, `allowed-tools`
2. Pipeline line: flow with `^current` marker
3. Skills list
4. Docs path resolution: `basename` of git root, overridable via `~/dev/docs/settings.json` → `~/dev/docs/<project>/<epic-slug>/`
5. Error handling: missing inputs → suggest which command to run first
6. No auto-commit

## Implementation order

| #   | Command                 | Type            | Status                                      |
| --- | ----------------------- | --------------- | ------------------------------------------- |
| 0   | `p-epic`                | Rename + update | Done                                        |
| 1   | `p-architecture`        | New             | Done                                        |
| 2   | `p-personas`            | New             | Deferred                                    |
| 3   | `p-story`               | Rename + update | Rename from `story.md`, add pipeline/skills |
| 4   | `p-task`                | New             |                                             |
| 5   | `p-review`              | New             |                                             |
| 6   | `p-review-unhappy-path` | New             |                                             |
| 7   | `p-review-security`     | New             |                                             |
| 8   | `p-review-bugs`         | New             |                                             |
| 9   | `p-review-qa`           | New             |                                             |
| 10  | `p-review-issue`        | New             |                                             |
| 11  | `p-pr`                  | Rename + update | Rename from `pr.md`                         |
| 12  | `p-pr-comments`         | New             |                                             |
