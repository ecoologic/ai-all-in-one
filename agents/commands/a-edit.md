---
description: Revise one planning artifact from feedback using its original command contract
argument-hint: <artifact-type> [selector...] <feedback>
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Skill]
---

# Artifact Revision

This command revises an existing planning artifact after user feedback:
```text
a-global-architecture -> a-epic -> a-architecture -> a-story(s) -> a-criterion(s)
                    \______________________________________________/
                                  a-edit can revisit any planning artifact
```

Use this command to correct or refine an artifact that already exists. Do not rerun the whole pipeline.

### Pipeline I/O

| Direction              | File                                | Description                                                                                              |
| ---------------------- | ----------------------------------- | -------------------------------------------------------------------------------------------------------- |
| **In**                 | owner command file                  | The original `a-*` command spec that defines the artifact contract, required inputs, and allowed updates |
| **In**                 | target planning artifact            | The current artifact being revised                                                                       |
| **In**                 | original command inputs             | The same planning inputs the owner command requires for that artifact type                               |
| **Conditional In**     | codebase                            | Read only when the owner command for the target artifact is code-informed                                |
| **Conditional In/Out** | `./planning/glossary.md`            | Update only when the owner command would have allowed a durable terminology promotion                    |
| **Conditional In/Out** | `./planning/global-architecture.plan.md` | Update only when the owner command would have allowed a durable cross-epic promotion                     |
| **Out**                | target planning artifact            | Revised artifact that addresses the user's feedback without discarding valid existing content            |

## Supported Targets

| Artifact Type         | Selector                     | Owner Command            | Target Artifact                                        |
| --------------------- | ---------------------------- | ------------------------ | ------------------------------------------------------ |
| `global-architecture` | none                         | `/a-global-architecture` | `./planning/global-architecture.plan.md`               |
| `glossary`            | none                         | `/a-global-architecture` | `./planning/glossary.md`                               |
| `epic`                | none                         | `/a-epic`                | `./planning/<epic-slug>/epic.md`                       |
| `personas`            | none                         | `/a-epic`                | `./planning/<epic-slug>/personas.md`                   |
| `stretch-goals`       | none                         | `/a-epic`                | `./planning/<epic-slug>/stretch-goals.md`              |
| `architecture`        | none                         | `/a-architecture`        | `./planning/<epic-slug>/architecture.plan.md`          |
| `story`               | `<story-number>`             | `/a-story`               | `./planning/<epic-slug>/story-<story-number>.md`       |

## Skills

Invoke the same skills the owner command would have used when the revision touches the same concerns.

Common examples:
- `explore` for targeted codebase investigation when revising `architecture` or `story`
- `ux-laws` when revising user-facing story or epic framing
- `react-best-practices` and `typescript-best-practices` only when the owner contract requires code-informed UI investigation
- `mermaid-diagrams` when a diagram change materially improves the revised artifact

## Purpose

Revise one planning artifact from concrete feedback while preserving the original pipeline contract.

This command should:
- reload the original owner command contract instead of guessing the artifact's shape
- anchor on the already open planning artifact when it clearly matches the request
- reread the inputs that justified the artifact originally
- compare the current artifact against the feedback and the owner contract
- apply the smallest durable revision that addresses the issue
- report any downstream artifacts that may now be stale or need reruns

## Rules

- NEVER edit more than one primary target artifact per run
- NEVER treat feedback as a request to regenerate the artifact from scratch unless the current artifact is unusable
- NEVER bypass the owner command contract; read the owner command file first
- NEVER let editor context override explicit user arguments
- NEVER silently rename glossary terms or durable architecture concepts
- NEVER write or modify application code
- NEVER write files outside `./planning/`
- NEVER widen scope into unrelated cleanup or speculative improvements
- For `story`, acceptance-criterion and implementation-task revisions still target the single `story-<story-number>.md` artifact
- Preserve still-correct content; revise only the sections needed to address the feedback
- If the requested change implies broader planning drift, summarize the affected artifacts and suggest reruns instead of silently rewriting everything
- Allow glossary or global-architecture promotion updates only when the owner command for the target artifact would have allowed them
- Use the currently open or visible planning artifact as a resolution hint only when it maps cleanly to a supported target
- Read the resolved target artifact before asking for section-level clarification unless the file is missing or the request is still genuinely ambiguous after reading it

## Step 1: Resolve arguments and local context

`$ARGUMENTS` = `<artifact-type> [selector...] <feedback>`

Parse explicit arguments from left to right:
1. first argument is the `artifact-type`
2. middle arguments are the selector required by that artifact type
3. final argument is the feedback text and should usually be quoted

Interpret selector shapes like this:
- epic selection is not accepted as a command argument for any `a-*` command
- for `story`, the only selector token is `<story-number>`
- for `epic`, `personas`, `stretch-goals`, and `architecture`, no selector token is accepted

Also inspect the currently open or visible planning artifact when that context is available. Treat it as a candidate target only if its path maps cleanly to one of the supported targets in this command.

Resolve target context in this precedence order:
1. explicit command arguments
2. currently open or visible planning artifact
3. `./planning/current.json` field `epic-slug` for epic-scoped targets
4. supported target table inference from the remaining context

Use the visible artifact to fill in omitted target details only when that fill is unambiguous. Examples:
- infer `epic` from an open file at `./planning/data-partners/epic.md`
- infer `story 7` from an open file at `./planning/data-partners/story-7.md`

For epic-scoped targets (`epic`, `personas`, `stretch-goals`, `architecture`, and `story`), read `./planning/current.json` and use its `epic-slug` value.

Examples:
- `/a-edit architecture "You missed the webhook retry flow"`
- `/a-edit story 2 "Acceptance criterion 2 does not cover authorization failures"` -> use the current epic and story `2`
- `/a-edit glossary "Use Subscription, not Plan, for the billing object"`
- `/a-edit epic "Split billing and activity into separate stories"` while `./planning/data-partners/epic.md` is open

If explicit arguments and the visible planning artifact disagree about the target, stop and ask the user which target to use. Do not guess.

If `artifact-type` is missing but the visible planning artifact cleanly identifies a supported target, use that target.

If `artifact-type` is present but the selector is missing, use the visible planning artifact to fill the selector only when the mapping is exact and conflict-free.

If the selector is still incomplete for an epic-scoped target after using visible context, use `./planning/current.json` only when its `epic-slug` field resolves the epic context exactly and conflict-free.

If `artifact-type` is missing, unsupported, or still does not have the required selector after applying the precedence rules, stop and show the supported target table.

If feedback is empty or missing, stop and ask the user to provide the issue to address.

If `./planning/current.json` is unreadable, malformed, or missing `epic-slug`, report that exact problem and stop.

## Step 2: Resolve the owner contract and target files

Map the `artifact-type` to its owner command and target artifact path using the supported targets table.

Read the owner command file first:
- `./agents/commands/a-global-architecture.md`
- `./agents/commands/a-epic.md`
- `./agents/commands/a-architecture.md`
- `./agents/commands/a-story.md`

Then read the current target artifact immediately.

Treat the artifact that is already open or visible in the editor as the first file candidate when it matches the resolved target path. Otherwise, read the resolved target path directly from `./planning/`.

If the target artifact does not exist, report the exact path checked and tell the user which owner command must produce it first.

If the feedback references a section, story number, heading, or acceptance criterion inside the target artifact, inspect the current file to resolve it before asking the user to paste more context.

Ask for section-level clarification only if:
- the file does not contain the referenced section or concept
- multiple plausible matches remain after reading the file
- the user's request conflicts with explicit arguments, visible context, or the owner contract

Extract from the owner command:
- the Pipeline I/O contract
- the required input files
- any followed-reference requirements
- the artifact structure or sections that should be preserved
- the allowed promotion targets and naming constraints

Output:
```text
Target type: <artifact-type>
Owner command: </a-...>
Target artifact: <path>
Resolution source: <explicit | visible artifact | mixed>
Feedback: <quoted feedback summary>
```

## Step 3: Reload the original inputs

Reload the same inputs the owner command would require for the resolved target artifact.

Derive those inputs from the owner command contract and the resolved artifact path. Do not require the user to restate the upstream file chain in the prompt.

Minimum required inputs by target:

- `global-architecture` or `glossary`
  - durable repo docs and architecture references
  - codebase read-only structure
- `epic`, `personas`, or `stretch-goals`
  - `./planning/<epic-slug>/idea.md`
  - `./planning/glossary.md`
  - `./planning/global-architecture.plan.md`
- `architecture`
  - `./planning/<epic-slug>/idea.md`
  - `./planning/<epic-slug>/epic.md`
  - `./planning/<epic-slug>/personas.md`
  - `./planning/glossary.md`
  - `./planning/global-architecture.plan.md`
  - targeted codebase areas needed to validate the feedback
- `story`
  - `./planning/<epic-slug>/epic.md`
  - `./planning/<epic-slug>/architecture.plan.md`
  - `./planning/<epic-slug>/personas.md`
  - `./planning/glossary.md`
  - `./planning/global-architecture.plan.md`
  - targeted codebase areas needed to validate the feedback

Also follow any references that the owner command says are required for that target. If any required input or followed reference is missing or unreadable, stop and report the exact path or reference.

If the owner command is code-informed, use only targeted exploration around the feedback. Do not do broad repo exploration.

If all required inputs can be resolved from the owner contract and the artifact path, keep going without asking the user to relink them manually.

## Step 4: Diagnose the requested revision

Compare:
1. the user's feedback
2. the current target artifact
3. the owner command contract
4. the reloaded inputs

Classify the revision request before editing:
- **missing content**: valid required content was omitted
- **incorrect content**: artifact contradicts source inputs or codebase truth
- **scope correction**: artifact boundaries, sequencing, or dependencies are wrong
- **naming correction**: terminology conflicts with the glossary or durable code names
- **stale artifact**: later discoveries invalidated part of the artifact

If the feedback conflicts with prior approvals, glossary canon, or durable repo-wide architecture:
- surface the conflict explicitly
- ask the user before changing the target

If the feedback is really a request to rerun the entire owner stage, say so explicitly and stop instead of faking a narrow edit.

## Step 5: Apply the constrained revision

Edit the target artifact in place.

When revising:
- preserve the file's existing structure unless the owner command contract requires a structural fix
- update only the sections needed to address the feedback
- keep all unaffected valid content
- prefer additive or surgical edits over full rewrites
- keep terminology aligned with `glossary.md`

Allowed promotion updates:
- update `./planning/glossary.md` only when the owner command for the target artifact would have allowed a durable terminology update
- update `./planning/global-architecture.plan.md` only when the owner command for the target artifact would have allowed a durable cross-epic update

If a promotion update is needed, keep it minimal and summarize it separately from the primary artifact revision.

## Step 6: Assess downstream impact

After editing, determine which downstream artifacts may now be stale.

Use these defaults unless the specific change proves otherwise:
- editing `global-architecture.plan.md` may affect every epic-specific artifact
- editing `glossary.md` may affect every artifact that uses the renamed or corrected term
- editing `epic.md` may affect `personas.md`, `architecture.plan.md`, and `story-*.md` for that epic
- editing `personas.md` may affect `architecture.plan.md` and `story-*.md` for that epic
- editing `stretch-goals.md` usually has no downstream effect on the active pipeline unless a now-work vs later-work boundary changed
- editing `architecture.plan.md` may affect `story-*.md` and future `/a-criterion` runs for that epic
- editing `story-<story-number>.md` may affect future `/a-criterion` runs for that story

Do not silently rewrite those downstream artifacts in the same run unless the owner rules explicitly require a minimal promotion update.

## Step 7: Present the revision

Summarize:
1. target artifact revised
2. exact issue addressed
3. sections changed
4. any promotion updates applied
5. affected artifacts and suggested reruns
6. any conflicts or remaining risks

Always include this section in the final output:

```text
Affected artifacts / suggested reruns:
- <artifact or none>: <why>
```

Ask the user to review the revision before advancing the pipeline again.

## Success Criteria

- [ ] the target artifact was resolved from a supported `artifact-type`
- [ ] explicit arguments took precedence over editor context when both were present
- [ ] the owner command file was read before revising the artifact
- [ ] the target artifact was read before asking for section-level clarification
- [ ] all required inputs and followed references were reloaded or the run stopped with an exact missing path
- [ ] the requested feedback was addressed without broad regeneration
- [ ] glossary and global architecture constraints were preserved
- [ ] any downstream impact was summarized explicitly
- [ ] the user was asked to review the revised artifact before the pipeline advanced

## Error Handling

- **Unsupported `artifact-type`** — show the supported targets table and stop
- **Missing selector for the chosen target** — explain the required selector shape and stop
- **Unexpected epic selector** — explain that epic-scoped `/a-edit` targets always use `./planning/current.json` and do not accept an epic slug argument
- **Invalid `./planning/current.json`** — report the exact issue with the missing or malformed `epic-slug` field and stop
- **Missing feedback text** — ask the user to provide the issue to address
- **Explicit target conflicts with visible planning artifact** — show both resolutions and ask the user which target to revise
- **Missing target artifact** — report the exact path checked and tell the user which owner command must create it first
- **Missing required input or followed reference** — report the exact path or reference and stop instead of skipping it
- **Feedback conflicts with glossary or durable architecture** — surface the conflict and ask the user before editing
- **Requested change is too broad for a constrained revision** — recommend rerunning the owner command and explain why
- **Requested change would require writing application code** — stop and tell the user this command only revises planning artifacts
