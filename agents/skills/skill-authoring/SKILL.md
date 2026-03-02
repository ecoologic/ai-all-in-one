---
name: skill-authoring
description: >-
  Use when creating a new skill, editing a SKILL.md file, running `npx skills init`,
  or when the user asks to write, improve, or review a skill's structure.
  Guide for writing highly effective Claude Code skills.
---

# Skill Authoring

Write skills that trigger reliably, load efficiently, and produce consistent quality results.

## When to use

- Creating a new skill from scratch or via `npx skills init`
- Editing or reviewing an existing SKILL.md
- User asks "how do I write a skill", "make a skill for X", "improve this skill"

## When NOT to use

- Installing or updating skills (use `find-skills` or `npx skills` CLI)
- Auditing skill accuracy against upstream docs (use `skill-review`)

---

## How Skills Work: Progressive Disclosure

Claude Code loads skills in three stages. Write for all three.

| Stage             | What loads                          | Budget                       | Your job                                |
| ----------------- | ----------------------------------- | ---------------------------- | --------------------------------------- |
| **1. Discovery**  | `name` + `description` only         | ~100 words across ALL skills | Make `description` trigger-rich         |
| **2. Activation** | Full SKILL.md body                  | < 500 lines                  | Keep it lean, imperative, example-heavy |
| **3. On demand**  | Bundled files (references, scripts) | No hard limit                | Move verbose reference material here    |

The description is the ONLY thing Claude sees at startup. If triggering fails, nothing else matters.

---

## Frontmatter Reference

Every field available in the YAML frontmatter block:

```yaml
---
# REQUIRED (effectively)
name:
  my-skill # Lowercase, hyphens only. Max 64 chars.
  # Cannot contain "anthropic" or "claude"
description: >- # Max 1024 chars. THE most important field.
  WHEN to trigger first, then what it does.
  Include file types, user phrases, key verbs.

# INVOCATION CONTROL
user-invocable: true # true = appears in /slash menu (default)
disable-model-invocation: false # true = ONLY user can invoke, Claude cannot auto-trigger
allowed-tools: Read, Grep, Glob # Tools allowed without permission prompts
argument-hint: "[filename]" # Shown in autocomplete, e.g. [issue-number]

# EXECUTION CONTEXT
context: fork # "fork" = run in isolated subagent context
agent: Explore # Subagent type when context: fork. Options: Explore, Plan, general-purpose
model: sonnet # Override model for this skill

# METADATA (for skills.sh ecosystem, not Claude Code itself)
metadata:
  author: owner/repo
  version: "1.0.0"
---
```

### Invocation control matrix

| Setting                          | User can invoke | Claude can invoke | Description in context |
| -------------------------------- | :-------------: | :---------------: | :--------------------: |
| defaults                         |       yes       |        yes        |          yes           |
| `disable-model-invocation: true` |       yes       |        no         |           no           |
| `user-invocable: false`          |       no        |        yes        |          yes           |

---

## Writing the Description

The description is a trigger mechanism, not documentation. Write it to maximize correct activation.

### Rules

1. **Lead with WHEN, then WHAT.** Claude picks skills by scanning descriptions at startup — trigger conditions must come first
2. **Be pushy about triggering.** Under-triggering is far more common than over-triggering
3. **Name file types, user phrases, and key verbs.** Claude is matching against these
4. **Write in third person.** The description is injected into a system prompt
5. **Stay under ~300 chars** for the metadata-level budget (~100 words)

### Trigger pattern vocabulary

Use these established patterns in your description:

| Pattern                | When to use                  | Example                                        |
| ---------------------- | ---------------------------- | ---------------------------------------------- |
| `Must use when...`     | Always-on for file types     | `Must use when reading or writing .py files`   |
| `Use when...`          | Discretionary activation     | `Use when asked to review UI or audit design`  |
| `TRIGGER when:`        | Explicit code-level triggers | `TRIGGER when: code imports @anthropic-ai/sdk` |
| `DO NOT TRIGGER when:` | Prevent false positives      | `DO NOT TRIGGER when: code imports openai`     |

<example>
# Bad: passive, no trigger conditions, no specificity
description: Helps with PDF files

# Bad: first person, no file types, vague

description: I can help you process and manipulate PDF documents

# Good: when-first, third person, specific triggers

description: >-
Use when working with .pdf files or when the user mentions PDFs,
forms, or document extraction. Extracts text and tables from PDF
files, fills forms, merges documents.

# Good: mandatory trigger with exclusion, when-first

description: >-
TRIGGER when: code imports anthropic, @anthropic-ai/sdk, or claude_agent_sdk.
DO NOT TRIGGER when: code imports openai or other AI SDKs.
Builds apps with the Claude API or Anthropic SDK.
</example>

---

## Body Structure

The SKILL.md body is what loads on activation. Keep it under 500 lines. Use imperative phrasing — 94% compliance vs 73% for descriptive.

### Recommended sections

```markdown
# Skill Name

One-line summary of what this skill does and why.

## When to use

- Bullet list of activation scenarios

## When NOT to use

- Bullet list of exclusions (prevents false positives)

## [Core instruction sections]

Imperative rules organized by topic. Use tables for checklists,
`<example>` blocks for code patterns, and IMPORTANT/NEVER/ALWAYS
for emphasis.

## [Reference sections — if needed]

Move verbose content to separate files and reference them:
"See `references/api-patterns.md` for the full API reference."
```

### Formatting rules

| Do                                                   | Don't                                                       |
| ---------------------------------------------------- | ----------------------------------------------------------- |
| Imperative: "Use X", "Return Y"                      | Descriptive: "We prefer X", "It's recommended to Y"         |
| `<example>` blocks for code patterns                 | Inline code in prose paragraphs                             |
| Tables for checklists and matrices                   | Long bullet lists > 7 items                                 |
| `IMPORTANT:`, `NEVER`, `ALWAYS`, `MUST` for emphasis | Overuse — if everything is important, nothing is            |
| One level of file references (SKILL.md → ref.md)     | Chains (SKILL.md → a.md → b.md)                             |
| Provide defaults: "Use pdfplumber"                   | Offer menus: "Choose between pypdf, pdfplumber, or PyMuPDF" |
| Explain WHY a rule exists (briefly)                  | Rigid rules without rationale                               |

### String substitutions available in body

| Variable               | Expands to                                                 |
| ---------------------- | ---------------------------------------------------------- |
| `$ARGUMENTS`           | All arguments passed on invocation                         |
| `$ARGUMENTS[0]`, `$0`  | First argument                                             |
| `${CLAUDE_SESSION_ID}` | Current session ID                                         |
| `` !`command` ``       | Shell command output (injected before Claude sees content) |

---

## File Organization

```
my-skill/
├── SKILL.md                # Required. Under 500 lines.
├── references/             # Optional. Loaded on demand.
│   ├── api-patterns.md
│   └── migration-guide.md
├── examples/               # Optional. Loaded on demand.
│   └── usage.md
└── scripts/                # Optional. Executed, not loaded.
    └── validate.sh
```

One level of references only. SKILL.md can point to `references/api-patterns.md`, but that file should not point to another file.

---

## Skill Template

Use this as a starting point. Delete sections that don't apply.

```markdown
---
name: my-skill
description: >-
  [TRIGGER pattern]: [when to activate].
  [DO NOT TRIGGER pattern]: [when to skip — if needed].
  [What it does in one sentence].
argument-hint: "[arg-name]"
allowed-tools: Read, Grep, Glob
---

# [Skill Name]

[One sentence: what this skill does and why it exists.]

## When to use

- [Scenario 1: file type, user phrase, or action]
- [Scenario 2]

## When NOT to use

- [Exclusion 1: what this skill should NOT handle]
- [Exclusion 2]

---

## [Core Section 1]

[Imperative rules. Keep each section focused on one topic.]

| Rule         | Rationale            |
| ------------ | -------------------- |
| [Do X]       | [Why — one sentence] |
| NEVER [do Y] | [Why — one sentence] |

<example>
// Good: [brief label]
[code or pattern]

// Bad: [brief label]
[code or pattern]
</example>

## [Core Section 2]

[More rules, tables, examples as needed.]

IMPORTANT: [Critical rule that must not be missed.]

<example>
[Another code example]
</example>
```

---

## Quality Checklist

Run through before publishing:

| Check                                                        | Pass? |
| ------------------------------------------------------------ | ----- |
| `description` leads with WHEN, then WHAT?                    |       |
| `description` under 300 chars?                               |       |
| Body under 500 lines?                                        |       |
| All instructions use imperative phrasing?                    |       |
| Every code pattern wrapped in `<example>`?                   |       |
| No duplicate content with existing skills?                   |       |
| Bundled references are one level deep max?                   |       |
| IMPORTANT/NEVER/ALWAYS used sparingly (< 5 per skill)?       |       |
| Works with Haiku (enough detail) and Opus (not insulting)?   |       |
| No time-sensitive content (dates, version numbers that rot)? |       |
