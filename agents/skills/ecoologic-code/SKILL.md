---
name: ecoologic-code
description: "MUST USE, when writing or modifying application code. TRIGGER when: creating features, refactoring domain logic, reviewing PRs, or building UI. Takes precedence over other coding skills. Authors good code."
allowed-tools: Read, Grep, Glob, Edit, Write
model: sonnet
---

# Ecoologic Code

## Pair with other skills

Always load relevant companion skills alongside:

- `ecoologic-architecture` — MUST load alongside (shared principles for planning and coding)
- React → `react-best-practices` (covers hooks, effects, refs, component design)

## When to use

- Writing or modifying application/domain code
- Designing new features, modules, or services
- Refactoring existing code toward domain alignment
- Any PR or code review involving business logic
- Building or reviewing user-facing interfaces

## When NOT to use

- Pure infrastructure/DevOps (Dockerfiles, CI pipelines)
- One-off scripts with no domain model
- Documentation-only changes

## TypeScript

- DO NOT CREATE any new enums, EVER, it's fine to use existing ones, use simple strings and use consts for the values (grouped in an object eg: `{ green: 'green' } as const`) and type it strictly
- Use `as const` where possible but not redundant
- Use TypeScript type guards when possible `const isNumber = (value: unknown): value is number => {`
  Note that these have high chances of reusability and should be stored closed to the type they assert
- Try to avoid optional types (eg: `active?: boolean`), there's probably a better way to type or code to write more confident code
- NEVER create new magic numbers, extract to const for clarity
- Use `typeof` and `keyof typeof` to reduce duplication

## Tests

- ALWAYS write a test after fixing a bug when none existed that was failing

## Code Style

- ALWAYS prefer confident and simple code
- ALWAYS prefer declarative style over imperative
- ALWAYS prefer functional or object-oriented, and avoid procedural
- Avoid declaring function inside other functions, prefer root functions when possible
- We strictly control for quality and security at the edges (eg: endpoints); Once in, we assume information is correct, eg: Do not re-validate internal data (eg: from the DB)
- Avoid intermediate variables when inline is sufficient

## Readability

- Once a concept is set, do not shorten it when used as pre/postfixes eg: `DataPartner -> DataPartnerExtractionConfig` not just `PartnerExtractionConfig`
- ALWAYS use the domain's exact terms. If the business says "Shipment", code `Shipment`, not `Delivery`
- The name depends and indicates what the value is. So, for example, `billingChoice` is always the object, NEVER the id, that would be `billingChoiceId` and `company` is a terrible name for `companyName`, eg: `DOMAIN -> DOMAIN_URL`
- One word in English, one word in code: `separateEachWord`, NEVER `jamwordstogether`
- NEVER use synonyms, don't cheat when: you already have a name and you need a new one, the solution might be to make the older name more specific, and use the same level of specificity for the new name

## Shared code and module boundaries

- Evaluate extracted or shared code in this order:
  1. semantic ownership
  2. conceptual correctness
  3. dependency direction
  4. existing architectural boundaries
  5. locality / convenience LAST
- If duplication is discovered in one feature, the extraction must be stored based on meaning, not "vicinity"
- Extract shared logic to a module matching its domain (e.g., auth/, billing/)
- Put logic where it belongs by meaning and ownership, not where duplication first appears
- If logic is generic, place it in a generic boundary even if it is currently used by only one feature
- If logic is domain-specific, place it with that domain even if some parts look technically reusable
- Backend transport and error-shaping logic MUST stay backend-local; NEVER leak internals to the user
  - a narrowly-scoped technical `helpers` module can be acceptable when the project already uses it intentionally, but do not turn it into a catch-all shared bucket
- Prefer colocating code with the hook, component, feature, or domain object that truly owns its meaning. Locality is a tie-breaker, not the primary rule
- Dependency direction still matters after extraction: avoid creating "shared" modules that pull lower-level code upward or cause unrelated features to depend on a vague common bucket
- MANDATORY checkpoint for every new shared file or module:
  - Who owns this?
  - Why does it live here?
  - Is the current location the owner, or only the first consumer?
  - Is this grouped by feature or by tech type?
  - Does this placement respect dependency direction and architectural boundaries?
  - If there were no duplicate yet, where would this code naturally belong?

## Security

- NEVER expose raw code errors and internals to the user, neither in UIs or APIs

## Monitoring

- NEVER hide errors, make sure logging has the original error

## Error Handling

- Internally store all the information for future debugging
- NEVER expose internal details to clients, ALWAYS map internal errors to user friendly versions at API level

## YAGNI

1. **Build only what is needed now.** No speculative features, no "might need later" abstractions
2. **YAGNI does NOT restrict refactoring or extractions.** Making code clearer and defining the correct specific abstractions makes for easier maintenance and it's always allowed
