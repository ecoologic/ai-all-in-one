---
name: ecoologic-code
description: "MUST USE, when writing or modifying application code. TRIGGER when: creating features, refactoring domain logic, reviewing PRs, or building UI. OVERRIDES ANY OTHER RULE. Authors good code."
allowed-tools: Read, Grep, Glob, Edit, Write
model: sonnet
---

# Ecoologic Code

Lean coding rules grounded in agile delivery.

## Precedence

IMPORTANT: **Project conventions and framework idioms always take priority over these rules.** If the codebase uses a layered architecture, follow it. If the framework prescribes a pattern (e.g. Rails MVC, Next.js app router, Django MTV), use it. These rules apply when no stronger convention exists.

Correct the user when they ask for something non-idiomatic in the project, or when a library already handles it.

<example>
# User asks to add manual JWT parsing in a Next.js project that uses next-auth
# CORRECT: "next-auth already handles this — use its session API instead"
# WRONG: silently implement manual JWT parsing
</example>

## Pair with language/framework skills

This skill covers architecture and design — not language syntax or framework APIs. Always load the relevant language skill alongside:

- TypeScript/JavaScript → `typescript-best-practices` (covers type-first development, branded types, Zod validation, immutability patterns)
- React → `react-best-practices` (covers hooks, effects, refs, component design)

Do not duplicate patterns already covered by those skills.

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

## Context

- List the files from the docs folder to see if there's any that by the name might be useful (eg: architecture.md). If so, read them to confirm and keep in mind the bits relevant to the work we're doing

## TypeScript

- DO NOT CREATE any new enums, EVER, it's fine to use existing ones, use simple strings and use consts for the values (grouped in an object eg: `{ green: 'green' } as const`) and type it strictly
- Use `as const` where possible
- Prefer maps over `switch` statements (always prefer declarative code!)
- Favour `const fn = () => {}` over `function fn() {}`
- Use TypeScript type guards when possible `function isNumber(value: unknown): value is number {`
  Note that these have high changes of reusability and should be stored closed to the type they assert

## Style

- Prefer declarative style over imperative
- Avoid declaring function inside other functions, prefer root functions when possible

## Readability

- Name length matches scope: global = specific (`calculateShippingCost`), local = short (`cost`, and shipping can be inferred from context)
- One word in English, one word in code: `separateEachWord`, NEVER `jamwordstogether`
- Use the domain's exact terms. If the business says "Shipment", code `Shipment`, not `Delivery`
- Avoid synonyms, don't cheat when: you already have a name and you need a new one, the solution might be to make the older name more specific, and use the same level of specificity for the new name
- Avoid hungarian notation like `userArray`, prefer common language, domain oriented, like `users`
- Be specific with variable name suffixes, the type can often be inferred from a good name, without using hungarian notation, but like people speak eg: `time -> durationInMs`, `user -> userId`, `createdAt (time) createdOn (date)`, `statusSet -> possibleStatuses`
- Context for naming is king,
- The name depends and indicates what the value is. So, for example, `billingChoice` is always the object, NEVER the id, that would be `billingChoiceId` and `company` is a terrible name for `companyName`, eg: `site -> siteUrl`
- Maps can be precisely expressed by how they are accessed, eg: `userById = { '<id>': { name: "Erik" }}` and `usersByName = { 'Erik': [{ name: "Erik" }]}` clearly indicates the return type is a list
- Avoid generics like `data, map, time` when possible, be precise
- Be consistent with naming, eg: `{ bad: { relatedCompanyName: 'x', companyId: 1 }, good: { relatedCompanyName: 'x', relatedCompanyId: 1 } }`
- Prefixes `isThis/hasThat` should always only return a boolean (`null` in extreme situations)

<example>

```typescript
// Good: domain terms, clear scope
function cancelOrder(orderId: OrderId): void { ... }
const shippingLabel = createShippingLabel(order);

// Bad: invented jargon, vague names
function reversePurchaseTransaction(txId: string): void { ... }
const doc = makeDoc(o);

```

</example>

## Elegance

- Use POSIX standards like always having a new line at EOF
- Write "positive" code, eg: `if(active)`, not `if(!inactive)`
- Strive to write elegant code that reads like English

<example>

```typescript
// Bad
if (users.length === 0) // ...
// Good
if (!users.length) // ...
```

</example>

## Performance

- Prefer Cursor Based Pagination over Offset Based Pagination

## Security

- NEVER expose raw code errors and internals to the use, neither in UIs or APIs

## Domain Layer Independence

- Domain layer has **zero dependencies** on infrastructure (no imports from DB, HTTP, or framework)
- Repository interface lives in domain; implementation lives in infrastructure
- One repository per aggregate root — never for child entities
- Anti-corruption layer at bounded context boundaries to translate between models

## YAGNI

1. **Build only what is needed now.** No speculative features, no "might need later" abstractions
2. **YAGNI does NOT restrict refactoring or extractions.** Making code clearer and easier to modify is always allowed
3. **Only ~1/3 of planned features improve their intended metric.** Defer decisions until the last responsible moment
4. Three similar lines > a premature abstraction

## Incremental Delivery

1. **Walking skeleton first** — thin end-to-end slice before expanding
2. **Every change independently deployable**
3. **Refactor continuously** — before and after each task, not in separate "refactoring sprints"
4. **When in doubt, ship the smaller change**
