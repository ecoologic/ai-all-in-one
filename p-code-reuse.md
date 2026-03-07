# Code Reuse Plan

> Status: parked
> Purpose: capture the current design for a shared reuse artifact without implementing it yet.

## Recommendation

A reusable-code artifact is a good idea if it stores concrete, evidence-backed candidates rather than becoming a second architecture diary.

Current direction:
- global JSON file at `./tmp/planning/reusable-code.json`
- seeded by `/p-architecture`
- consumed and refined by `/p-story`
- available later to `/p-task`

## Proposed Contents

Use a JSON array of objects. Keep it structured enough for AI consumption and downstream command handoff.

Recommended fields:
- `id`: stable identifier for the candidate
- `kind`: `component | hook | service | model | type | util | pattern | route | test`
- `file_path`: source file
- `signature`: optional symbol, export, or route signature
- `description`: short summary
- `recommended_action`: `reuse | extend | extract | follow-pattern | investigate`
- `system_area`: high-level area such as `ui`, `api`, `shared-types`
- `source_kind`: `repo | prototype`
- `applies_to`: epic/story references
- `constraints`: short list of caveats
- `status`: `candidate | validated | rejected | stale`

This goes beyond `{ file_path, signature, description }`, which is too weak to express whether something should be reused, extended, extracted, or only used as a pattern.

## Command Impact

Update `agents/commands/p-architecture.md`:
- add `./tmp/planning/reusable-code.json` as `In/Out`
- emit structured reuse candidates during exploration and reuse analysis
- keep durable structure in `global-architecture.md`, and tactical reuse candidates in `reusable-code.json`

Update `agents/commands/p-story.md`:
- read `./tmp/planning/reusable-code.json` before fresh exploration
- start from matching reuse entries during codebase investigation
- validate or refine candidate status at the story level

Update `p-plan.md`:
- document the new artifact path and ownership rules
- keep the responsibilities distinct:
- `glossary.md` = naming source of truth
- `global-architecture.md` = durable structure
- `reusable-code.json` = concrete reuse and extraction candidates

## Staleness Guardrails

To prevent stale cache behavior:
- never add vague "might be useful" entries
- require every entry to reference a real file or explicit prototype source
- update `status` instead of duplicating near-identical candidates
- use `last_validated_at` and refresh-on-read behavior once implemented
- mark disproven entries as `rejected` or `stale`

## Pending Work

1. Define the final JSON schema and lifecycle rules.
2. Update `/p-architecture` to read and write the shared reuse artifact.
3. Update `/p-story` to consume and refine the artifact.
4. Update `p-plan.md` to document the artifact and its boundaries.
