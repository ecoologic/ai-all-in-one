---
description: Revise one planning artifact from feedback using its original command contract
argument-hint: <artifact-type> [selector...] <feedback>
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Skill]
---

# Artifact Revision

This command revises an existing planning artifact after user feedback:
```text
a-global-architecture -> a-epic -> a-architecture -> a-story(s) -> a-task(s)
                    \______________________________________________/
                                  a-edit can revisit any planning artifact
```

Use this command to correct or refine an artifact that already exists. Do not rerun the whole pipeline stage unless the requested change is broad enough that a full regeneration is safer than a targeted revision.

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | owner command file | The original `a-*` command spec that defines the artifact contract, required inputs, and allowed updates |
| **In** | target planning artifact | The current artifact being revised |
| **In** | original command inputs | The same planning inputs the owner command requires for that artifact type |
| **Conditional In** | codebase | Read only when the owner command for the target artifact is code-informed |
| **Conditional In/Out** | `./tmp/planning/glossary.md` | Update only when the owner command would have allowed a durable terminology promotion |
| **Conditional In/Out** | `./tmp/planning/global-architecture.md` | Update only when the owner command would have allowed a durable cross-epic promotion |
| **Out** | target planning artifact | Revised artifact that addresses the user's feedback without discarding valid existing content |

## Supported Targets

| Artifact Type | Selector | Owner Command | Target Artifact |
| ------------- | -------- | ------------- | --------------- |
| `global-architecture` | none | `/a-global-architecture` | `./tmp/planning/global-architecture.md` |
| `glossary` | none | `/a-global-architecture` | `./tmp/planning/glossary.md` |
| `epic` | `<epic-slug>` | `/a-epic` | `./tmp/planning/<epic-slug>/epic.md` |
| `personas` | `<epic-slug>` | `/a-epic` | `./tmp/planning/<epic-slug>/personas.md` |
| `stretch-goals` | `<epic-slug>` | `/a-epic` | `./tmp/planning/<epic-slug>/stretch-goals.md` |
| `architecture` | `<epic-slug>` | `/a-architecture` | `./tmp/planning/<epic-slug>/architecture.md` |
| `story` | `<epic-slug> <story-number>` | `/a-story` | `./tmp/planning/<epic-slug>/story-<story-number>.md` |
| `story-tasks` | `<epic-slug> <story-number>` | `/a-story` | `./tmp/planning/<epic-slug>/story-<story-number>-tasks.md` |

## Skills

Invoke the same skills the owner command would have used when the revision touches the same concerns.

Common examples:
- `explore` for targeted codebase investigation when revising `architecture`, `story`, or `story-tasks`
- `ux-laws` when revising user-facing story or epic framing
- `react-best-practices` and `typescript-best-practices` only when the owner contract requires code-informed UI investigation
- `mermaid-diagrams` when a diagram change materially improves the revised artifact

## Purpose

Revise one planning artifact from concrete feedback while preserving the original pipeline contract.

This command should:
- reload the original owner command contract instead of guessing the artifact's shape
- reread the inputs that justified the artifact originally
- compare the current artifact against the feedback and the owner contract
- apply the smallest durable revision that addresses the issue
- report any downstream artifacts that may now be stale or need reruns

## Rules

- NEVER edit more than one primary target artifact per run
- NEVER treat feedback as a request to regenerate the artifact from scratch unless the current artifact is unusable
- NEVER bypass the owner command contract; read the owner command file first
- NEVER silently rename glossary terms or durable architecture concepts
- NEVER write or modify application code
- NEVER write files outside `./tmp/planning/`
- NEVER widen scope into unrelated cleanup or speculative improvements
- Preserve still-correct content; revise only the sections needed to address the feedback
- If the requested change implies broader planning drift, summarize the affected artifacts and suggest reruns instead of silently rewriting everything
- Allow glossary or global-architecture promotion updates only when the owner command for the target artifact would have allowed them

## Step 1: Resolve arguments

`$ARGUMENTS` = `<artifact-type> [selector...] <feedback>`

Parse arguments from left to right:
1. first argument is the `artifact-type`
2. middle arguments are the selector required by that artifact type
3. final argument is the feedback text and should usually be quoted

Examples:
- `/a-edit architecture billing-reconciliation "You missed the webhook retry flow"`
- `/a-edit story billing-reconciliation 2 "The acceptance criteria do not cover authorization failures"`
- `/a-edit glossary "Use Subscription, not Plan, for the billing object"`

If `artifact-type` is missing, unsupported, or does not have the required selector, stop and show the supported target table.

If feedback is empty or missing, stop and ask the user to provide the issue to address.

## Step 2: Resolve the owner contract and target files

Map the `artifact-type` to its owner command and target artifact path using the supported targets table.

Read the owner command file first:
- `./agents/commands/a-global-architecture.md`
- `./agents/commands/a-epic.md`
- `./agents/commands/a-architecture.md`
- `./agents/commands/a-story.md`

Then read the current target artifact.

If the target artifact does not exist, report the exact path checked and tell the user which owner command must produce it first.

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
Feedback: <quoted feedback summary>
```

## Step 3: Reload the original inputs

Reload the same inputs the owner command would require for the target artifact.

Minimum required inputs by target:

- `global-architecture` or `glossary`
  - durable repo docs and architecture references
  - codebase read-only structure
- `epic`, `personas`, or `stretch-goals`
  - `./tmp/planning/<epic-slug>/idea.md`
  - `./tmp/planning/glossary.md`
  - `./tmp/planning/global-architecture.md`
- `architecture`
  - `./tmp/planning/<epic-slug>/idea.md`
  - `./tmp/planning/<epic-slug>/epic.md`
  - `./tmp/planning/<epic-slug>/personas.md`
  - `./tmp/planning/glossary.md`
  - `./tmp/planning/global-architecture.md`
  - targeted codebase areas needed to validate the feedback
- `story` or `story-tasks`
  - `./tmp/planning/<epic-slug>/epic.md`
  - `./tmp/planning/<epic-slug>/architecture.md`
  - `./tmp/planning/<epic-slug>/personas.md`
  - `./tmp/planning/glossary.md`
  - `./tmp/planning/global-architecture.md`
  - targeted codebase areas needed to validate the feedback

Also follow any references that the owner command says are required for that target. If any required input or followed reference is missing or unreadable, stop and report the exact path or reference.

If the owner command is code-informed, use only targeted exploration around the feedback. Do not do broad repo exploration.

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
- update `./tmp/planning/glossary.md` only when the owner command for the target artifact would have allowed a durable terminology update
- update `./tmp/planning/global-architecture.md` only when the owner command for the target artifact would have allowed a durable cross-epic update

If a promotion update is needed, keep it minimal and summarize it separately from the primary artifact revision.

## Step 6: Assess downstream impact

After editing, determine which downstream artifacts may now be stale.

Use these defaults unless the specific change proves otherwise:
- editing `global-architecture.md` may affect every epic-specific artifact
- editing `glossary.md` may affect every artifact that uses the renamed or corrected term
- editing `epic.md` may affect `personas.md`, `architecture.md`, `story-*.md`, and `story-*-tasks.md` for that epic
- editing `personas.md` may affect `architecture.md`, `story-*.md`, and `story-*-tasks.md` for that epic
- editing `stretch-goals.md` usually has no downstream effect on the active pipeline unless a now-work vs later-work boundary changed
- editing `architecture.md` may affect `story-*.md`, `story-*-tasks.md`, and future `/a-task` runs for that epic
- editing `story-<story-number>.md` may affect `story-<story-number>-tasks.md` and related `/a-task` runs
- editing `story-<story-number>-tasks.md` may affect future `/a-task` runs for that story

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
- [ ] the owner command file was read before revising the artifact
- [ ] all required inputs and followed references were reloaded or the run stopped with an exact missing path
- [ ] the requested feedback was addressed without broad regeneration
- [ ] glossary and global architecture constraints were preserved
- [ ] any downstream impact was summarized explicitly
- [ ] the user was asked to review the revised artifact before the pipeline advanced

## Error Handling

- **Unsupported `artifact-type`** — show the supported targets table and stop
- **Missing selector for the chosen target** — explain the required selector shape and stop
- **Missing feedback text** — ask the user to provide the issue to address
- **Missing target artifact** — report the exact path checked and tell the user which owner command must create it first
- **Missing required input or followed reference** — report the exact path or reference and stop instead of skipping it
- **Feedback conflicts with glossary or durable architecture** — surface the conflict and ask the user before editing
- **Requested change is too broad for a constrained revision** — recommend rerunning the owner command and explain why
- **Requested change would require writing application code** — stop and tell the user this command only revises planning artifacts
