---
description: Audit the previous response against all loaded rules and surface violations
argument-hint: [hint about what went wrong]
allowed-tools: [Read, Glob, Grep]
---

# Nope — Rule Violation Audit

Audit the most recent response (immediately before `/nope`) against every instruction loaded in this conversation. If $ARGUMENTS is provided, treat it as a hint about what the user suspects went wrong.

## Step 1: Capture the response under review

Re-read the last assistant response verbatim. Identify and quote:

1. **Key decisions** made (tool choices, structure, tone, format)
2. **Omissions** — anything conspicuously absent (missing sections, skipped steps)
3. **Assertions** — claims about what was done or why

Output a brief summary (3-5 bullets max):

```
Response under review:
- [decision/omission/assertion #1]
- [decision/omission/assertion #2]
- ...
```

DO NOT skip this step. The response must be fresh in context before auditing.

## Step 2: Enumerate and read all instruction sources

List every instruction source currently loaded in this conversation. Exclude project-specific application code and documentation — only include files that govern agent behaviour (CLAUDE.md, SKILL.md, command files, settings, system prompts).

Read each file now using the Read tool. Output a numbered reference list:

```
Instruction sources:
1. [path] — [one-line summary of what it governs]
2. [path] — [one-line summary]
...
```

## Step 3: Extract rules and cross-check against the response

For **each** instruction source from Step 2, perform the following:

1. Extract every directive, constraint, preference, or rule from that source
2. Compare each rule against the response summary from Step 1
3. Check $ARGUMENTS for additional clues about suspected violations
4. Flag any rule that was violated, partially followed, or ignored

For each violation found, record:

| # | Source | Rule (quoted) | What went wrong | Severity |
|---|--------|---------------|-----------------|----------|
| 1 | Source #N | `"<exact quote>"` | <specific failure> | high/medium/low |

Severity guide:
- **high** — directly contradicts an explicit MUST/NEVER/ALWAYS directive
- **medium** — ignores a SHOULD/preference or skips a required step
- **low** — misses a stylistic convention or soft guideline

## Step 4: Report findings

Output the final report in this format:

```
## /nope Audit Results

**Response audited**: [first 10 words of the response]...
**Sources checked**: [count]
**Rules extracted**: [count]
**Violations found**: [count]

### Violations

[table from Step 3]

### Summary

[One sentence: what category of rules was most violated and why]
```

If no violations are found, say so explicitly:

```
No violations detected across [N] sources and [M] rules.
The response appears compliant. If something still feels off,
re-invoke with a specific hint: /nope "the tone was wrong"
```

## Important Notes

- **NEVER fabricate violations** — only flag rules with exact quotes from instruction sources
- **NEVER skip Step 1** — reviewing the response first prevents confirmation bias when reading rules
- **DO NOT read application code** — only read instruction/config files
- **DO NOT suggest fixes** — this command diagnoses only; the user decides what to do next
- **STOP after the report** — do not take corrective action
