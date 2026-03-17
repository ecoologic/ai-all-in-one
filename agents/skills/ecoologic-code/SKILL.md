---
name: ecoologic-code
description: "MUST USE, when writing or modifying application code. TRIGGER when: creating features, refactoring domain logic, reviewing PRs, or building UI. Takes precedence over other coding skills. Authors good code."
allowed-tools: Read, Grep, Glob, Edit, Write
model: sonnet
---

# Ecoologic Code

Lean coding rules grounded in agile delivery.

## Precedence

IMPORTANT: **Project conventions and framework idioms always take priority over these rules.** If the codebase uses a layered architecture, follow it. If the framework prescribes a pattern (e.g. React Router conventions, Koa middleware chains, Zustand store patterns), use it. These rules apply when no stronger convention exists.

This skill takes precedence over other coding-style skills. Domain-specific skills (e.g. ux-laws, react-best-practices) are complementary — apply them alongside these rules, not instead of them.

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
If those skills contain relevant structure guidance (for example: colocating by feature, keeping hooks/components focused, or grouping files by feature rather than type), explicitly apply that guidance when reviewing or introducing modules. Do not judge an extraction only by abstraction quality while ignoring file ownership or placement.

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

- List the files including the word architecture in `./planning/` to see if there's any that by the name might be relevant to our goal. If so, read the sections that seem relevant.

## Testing

- For test-writing and test-review guidance, load `ecoologic-test`
- Keep this skill focused on application and domain code rules

## TypeScript

- DO NOT CREATE any new enums, EVER, it's fine to use existing ones, use simple strings and use consts for the values (grouped in an object eg: `{ green: 'green' } as const`) and type it strictly
- Use `as const` where possible
- Prefer maps over `switch` statements (always prefer declarative code!)
- Use TypeScript type guards when possible `function isNumber(value: unknown): value is number {`
  Note that these have high chances of reusability and should be stored closed to the type they assert
- Try to avoid optional types (eg: `active?: boolean`), there's probably a better way to type or code to write more confident code
- NEVER create new magic numbers, extract to const for clarity
- NEVER call a time `Xdate`, even if JS class is `Date`, a `date` is the day only, and `time` is a date _with time_

## Code Style

- Prefer declarative style over imperative
- Avoid declaring function inside other functions, prefer root functions when possible
- We strictly control for quality and security entering the system; Once in, we assume information is correct, eg: Do not re-validate data in the DB

## Readability

- Context for naming is king: Name specificity matches scope: global = specific (`calculateShippingCost`), local = short (`cost`, and shipping can be inferred from context)
- Once a name is set, do not shorten it when used as pre/postfixes eg: `DataPartner -> DataPartnerExtractionConfig` not just `PartnerExtractionConfig`
- The name depends and indicates what the value is. So, for example, `billingChoice` is always the object, NEVER the id, that would be `billingChoiceId` and `company` is a terrible name for `companyName`, eg: `site -> siteUrl`
- One word in English, one word in code: `separateEachWord`, NEVER `jamwordstogether`
- Use the domain's exact terms. If the business says "Shipment", code `Shipment`, not `Delivery`
- Avoid synonyms, don't cheat when: you already have a name and you need a new one, the solution might be to make the older name more specific, and use the same level of specificity for the new name
- Avoid hungarian notation like `userArray`, prefer common language, domain oriented, like `users`
- Be specific with variable name suffixes, the type can often be inferred from a good name, without using hungarian notation, but like people speak eg: `time -> durationInMs`, `user -> userId`, `createdAt (time) createdOn (date)`, `statusSet -> possibleStatuses`, `seatingSet -> seatingOptions`
- Maps can be precisely expressed by how they are accessed, eg: `userById = { '<id>': { name: "Erik" }}` and `usersByName = { 'Erik': [{ name: "Erik" }]}` clearly indicates the return type is a list
- Avoid generics like `data, map, time` when possible, be precise
- Be consistent with naming, eg: `{ bad: { relatedCompanyName: 'x', companyId: 1 }, good: { relatedCompanyName: 'x', relatedCompanyId: 1 }, better: { company: { id: 1, name: 'x' } } }`
- Prefixes `isThis/hasThat` should always only return a boolean (`null` in rare extreme situations)

<example>

```typescript
// Good: domain terms, clear scope
const cancelOrder = (orderId: OrderId): void => { ... }
const shippingLabel = createShippingLabel(order);

// Bad: invented jargon, vague names
const reversePurchaseTransaction = (txId: string): void => { ... }
const doc = makeDoc(o);
```

</example>

## Shared code and module boundaries

- Evaluate extracted or shared code across five axes: domain meaning, locality, ownership/location, dependency direction, and YAGNI/abstraction cost
- Distinguish two different problems:
  - the abstraction is bad
  - the abstraction is fine, but the module boundary or file location is bad
- Code should usually be grouped by feature, bounded context, or clear owner, not by technical shape such as `constants/`, `types/`, unless the project already has a stronger convention
  - `helpers` might be a good exception to extract tech jargon in one location
- Prefer colocating code with the hook, component, feature, or domain object that gives it meaning. Move it to a broader shared location only when multiple peers with the same owner truly need it
- Shared constants can be good when they remove arbitrary magic numbers, encode consistent UX defaults, or make behavior easier to tune. They still need a meaningful owner and should not be dumped into a global junk-drawer module
- Dependency direction still matters after extraction: avoid creating "shared" modules that pull lower-level code upward or cause unrelated features to depend on a vague common bucket
- In reviews and refactors, call out the real smell precisely. If the value is useful but the placement is wrong, say that explicitly instead of rejecting the extraction wholesale
- Mandatory checkpoint for every new shared file or module:
  - Who owns this?
  - Why does it live here?
  - Is this grouped by feature or by tech type?
  - Would colocating it with the hook or feature be clearer?

## Positive Code

- Avoid negative-named variables (`inactive`, `disabled`, `notFound`). Name variables for the positive case — negation of a positive reads naturally, double-negation of a negative doesn't

<example>

```typescript
// Bad — negative variable forces double-negative checks
const inactive = !user.lastLoginAt;
if (!inactive) { grantAccess(); }

// Good — positive variable, reads naturally
const active = !!user.lastLoginAt;
if (active) { grantAccess(); }
```

</example>

## Elegance

- Use POSIX standards like always having a new line at EOF
- Prefer idiomatic falsy/truthy checks over verbose comparisons
- Strive to write elegant code that reads like English

<example>

```typescript
// Bad — verbose comparison
if (users.length === 0) // ...
// Good — idiomatic falsy check
if (!users.length) // ...
```

</example>

## Performance

- Prefer Cursor Based Pagination over Offset Based Pagination

## Security

- NEVER expose raw code errors and internals to the user, neither in UIs or APIs

## API

- ALWAYS apply RESTful architecture for new "regular" endpoints (no GraphQL, RPC)

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
