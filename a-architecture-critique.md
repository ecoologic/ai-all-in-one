# `a-architecture` Rewrite Critique

These concerns came out of reviewing the current command before rewriting it. They are valid and should be treated as constraints for the new version.

## Valid concerns

1. The ERD should be inferred from all input files, not only the UI.
   - UI/prototype inputs are useful, but not authoritative.
   - PRDs, story text, screenshots, schema notes, and similar inputs can all contribute to the ERD.

2. The inferred ERD must be included in `architecture.md` for review.
   - The document should expose the model that was inferred from the inputs.
   - This makes weak assumptions visible before implementation starts.

3. The inferred ERD must also be criticized harshly.
   - Evaluate entity boundaries, ownership, naming, relationships, statuses, and nullability.
   - Challenge UI-shaped models and convenience-driven relationships.
   - Do this using both solid architecture practices and project conventions already present in the codebase.

4. The command should distinguish clearly between three things:
   - what the epic is trying to build
   - how the current system is structured
   - what architecture is recommended for this epic

5. `architecture.md` must stay epic-specific.
   - It should focus on the stories for the current epic.
   - It should not drift into a general repository map.

6. `global-architecture.md` must stay lean and cross-epic.
   - It should capture durable structural knowledge only.
   - It must not accumulate current-epic rationale, story-specific decisions, or temporary assumptions.

7.  `global-architecture.md` should include how the major parts communicate.
    - Examples: `ui -> api`, `api -> db`, background jobs, queues, webhooks, edge functions, external services.
    - These communication paths are cross-epic structural knowledge.

8.  The command needs a clear update filter for `global-architecture.md`.
    - Merge back only stable modules, boundaries, responsibilities, contracts, and communication paths.
    - Do not merge back epic-specific conclusions unless they become durable system structure.

9.  The command should define a source-of-truth hierarchy.
    - Existing code and stable project conventions beat prototype structure.
    - Input files beat guesswork.
    - The inferred ERD is a hypothesis, not truth.

10. The command should handle disagreement between inputs explicitly.
    - Do not silently reconcile conflicting models.
    - Surface contradictions and ask the user when they materially affect architecture decisions.

11. The command should avoid fabricating an ERD when the inputs are too weak.
    - If the model cannot be inferred with confidence, say so and record the gap.

12. Repo exploration language should be generic.
    - Use terms like system areas, modules, apps, services, packages, repositories, or layers as appropriate.
    - Avoid workspace-specific wording unless the repo actually uses workspaces.
