---
description: Use when told to find out what rules Claude did not follow in the previous response
argument-hint: <optional hint about what went wrong>
allowed-tools: [Read, Glob, Grep]
---

# Nope!

You have just been invoked because the user noticed your latest response violated instructions from the loaded context files or arguments.

## Step 1: Enumerate context sources

List every instruction source currently loaded in this conversation. Don't exclude any context file, but do not include project specific code or documentation.

Read each file now. Output a numbered reference list:

```
Context sources:
1. [path]
2. [path]
...
```

## Step 2: Audit the latest response

From each source, extract every directive, constraint, preference, or rule that governs your behaviour. For each, check it against your most recent response (the one immediately before the user invoked `/check-context`). Also check $ARGUMENTS for clues about what the user suspects.

For each violation found, note:
- Which instruction was broken
- Which source it came from
- What specifically went wrong

Output a numbered list:

```
Violations found:
1. [Source #N: "<quoted instruction>"] — <what went wrong>
2. ...
```

If no violations are found, say so explicitly and stop here.

## Step 3: Correct (after user confirmation)

For each violation, fix the issue. If the violation was in generated code, edit the code. If it was in your prose response, restate the corrected version.
