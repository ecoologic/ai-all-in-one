---
name: ecoologic-architecture
description: "Use alongside ecoologic-code or ecoologic-plan when designing features, refactoring module boundaries, or reviewing application structure; NOT for investigations or commits."
---

# Ecoologic Architecture

## Principles

- ALWAYS report findings before moving on to implementation — the user needs to see what you found before you act on it
- NEVER plan beyond the user's requested scope — scope creep wastes time and muddies intent
- ALWAYS search for code to reuse buried inside other features — duplication is the default failure mode; actively hunt for existing implementations before writing new ones
- ALWAYS extract code to be reused into the most natural location for its meaning (see ecoologic-code's "Shared code and module boundaries" section for placement rules)
- ALWAYS apply DRY even for two occurrences, extract based on meaning and domain, not based on vicinity
