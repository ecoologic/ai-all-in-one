---
name: ecoologic-code
description: >-
  Must use when writing or modifying application code.
  TRIGGER when: creating features, refactoring domain logic, reviewing PRs, or building UI.
  DO NOT TRIGGER when: pure DevOps, one-off scripts, or documentation-only changes.
  Domain-driven, vertical-slice coding subagent enforcing ubiquitous language,
  small aggregates, YAGNI, incremental delivery, readability, and Laws of UX.
allowed-tools: Read, Grep, Glob, Edit, Write
model: sonnet
---

# Ecoologic Code

Lean coding rules grounded in DDD tactical patterns, agile delivery, and UX laws.

## Precedence

IMPORTANT: **Project conventions and framework idioms always take priority over these rules.** If the codebase uses a layered architecture, follow it. If the framework prescribes a pattern (e.g. Rails MVC, Next.js app router, Django MTV), use it. These rules apply when no stronger convention exists, or when starting greenfield.

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

---

## Readability

- NEVER implement without explicit user agreement on the plan
- Name length matches scope: global = specific (`calculateShippingCost`), local = short (`cost`)
- One word in English, one word in code: `separateEachWord`, NEVER `jamwordstogether`
- Use the domain's exact terms. If the business says "Shipment", code `Shipment`, not `Delivery`

<example>
// Good: domain terms, clear scope
function cancelOrder(orderId: OrderId): void { ... }
const shippingLabel = createShippingLabel(order);

// Bad: invented jargon, vague names
function reversePurchaseTransaction(txId: string): void { ... }
const doc = makeDoc(o);
</example>

## Ubiquitous Language

Name everything — classes, methods, variables, modules — using the exact terms the domain uses.

- If the business says "Order", code `Order`, not `PurchaseRequest`
- If the business term changes, rename in code immediately — language drift is model drift
- Never invent technical synonyms for domain concepts

<example>
// Good: matches domain language
class ShippingLabel { ... }
function cancelOrder(orderId: OrderId): void { ... }

// Bad: invented technical jargon
class OutputDocument { ... }
function reversePurchaseTransaction(txId: string): void { ... }
</example>

## Value Objects First

Default to value objects. Promote to entity only when identity tracking is required.

1. **Immutable always.** No setters. To "change", return a new instance
2. **Equality by attributes.** Two value objects with the same fields are equal
3. **Validate in constructor.** An invalid value object cannot exist
4. **No side effects.** Methods return new value objects

<example>
// Value object: no identity, immutable, self-validating
class Money {
  readonly amount: number
  readonly currency: Currency

  constructor(amount: number, currency: Currency) {
    if (amount < 0) throw new InvalidAmount();
    this.amount = amount;
    this.currency = currency;
  }

  add(other: Money): Money {
    if (this.currency !== other.currency) throw new CurrencyMismatch();
    return new Money(this.amount + other.amount, this.currency);
  }
}

// For branded/opaque types and runtime validation, see typescript-best-practices
</example>

## Entities & Aggregates

1. **Entities have stable identity** — natural key or surrogate
2. **Behavior belongs in the entity**, not in service classes. Avoid anemic models
3. **Design aggregates small** — only data that must be consistent in one transaction
4. **Reference other aggregates by ID**, never by object reference
5. **Enforce all invariants inside the aggregate boundary**
6. **Cross-aggregate communication via domain events**, not direct calls

<example>
// Aggregate root: encapsulates invariants, references other aggregates by ID
class Order {
  static create(customerId: CustomerId): Order { ... }

  addItem(productId: ProductId, quantity: Quantity, price: Money): void {
    // Invariant enforced here, not in a service
    if (this.items.length >= MAX_LINE_ITEMS) throw new OrderTooLarge();
    this.items.push(new OrderItem(productId, quantity, price));
  }

  // Domain event, not a direct call to InventoryService
  confirm(): OrderConfirmed {
    if (this.items.length === 0) throw new EmptyOrder();
    this.status = 'confirmed';
    return new OrderConfirmed(this.id, this.items);
  }
}
</example>

## Vertical Slices

Organize code by feature, not by technical layer. **Defer to framework conventions when they exist** (e.g. Next.js app router already organizes by route).

1. **All code for one use-case lives together** — handler, validation, persistence
2. **Each slice picks its own patterns.** Simple CRUD doesn't need the same architecture as complex domain logic
3. **New features = new files.** Adding a feature should primarily add code, not modify shared infrastructure
4. **No mandatory abstractions.** Don't force Controller → Service → Repository when a direct handler suffices

<example>
# Good: organized by feature
features/
  create-order/
    handler.ts
    validation.ts
    repository.ts
  cancel-order/
    handler.ts
    policy.ts

# Bad: organized by layer
controllers/
  order-controller.ts
services/
  order-service.ts
repositories/
  order-repository.ts
</example>

## Domain Layer Independence

- Domain layer has **zero dependencies** on infrastructure (no imports from DB, HTTP, or framework)
- Repository interface lives in domain; implementation lives in infrastructure
- One repository per aggregate root — never for child entities
- Anti-corruption layer at bounded context boundaries to translate between models

## YAGNI

1. **Build only what is needed now.** No speculative features, no "might need later" abstractions
2. **YAGNI does NOT restrict refactoring.** Making code easier to modify is always allowed
3. **Only ~1/3 of planned features improve their intended metric.** Defer decisions until the last responsible moment
4. Three similar lines > a premature abstraction

## Incremental Delivery

1. **Walking skeleton first** — thin end-to-end slice before expanding
2. **Every change independently deployable**
3. **Refactor continuously** — before and after each task, not in separate "refactoring sprints"
4. **When in doubt, ship the smaller change**

---

## UX Laws

When building user-facing interfaces, apply these principles from Laws of UX. They complement — never override — the project's existing design system.

### Cognitive Load & Complexity

| Law | Rule |
|-----|------|
| **Miller's Law** | Keep groups to 7±2 items. Chunk information into digestible clusters |
| **Hick's Law** | Fewer choices = faster decisions. Reduce options at each step |
| **Cognitive Load** | Minimize mental effort. One primary action per screen |
| **Tesler's Law** | Complexity cannot be destroyed, only moved. Push it to the system, not the user |
| **Chunking** | Group related information into meaningful units (nav items, form sections, settings) |

### Perception & Attention

| Law | Rule |
|-----|------|
| **Law of Prägnanz** | People interpret complex shapes as the simplest form possible. Keep UI clean and unambiguous |
| **Law of Proximity** | Place related elements close together. Whitespace creates grouping |
| **Law of Similarity** | Visually similar elements are perceived as related. Consistent styling = clear relationships |
| **Law of Common Region** | Elements in a shared boundary (card, box, section) feel grouped |
| **Law of Uniform Connectedness** | Lines or shared background connect elements more strongly than proximity alone |
| **Von Restorff Effect** | The distinctive item gets remembered. Use contrast for CTAs and key information |
| **Selective Attention** | Users focus on what's relevant to their goal. Don't compete for attention with decoration |

### Behavior & Memory

| Law | Rule |
|-----|------|
| **Serial Position Effect** | Users remember first and last items best. Put critical actions at the start or end |
| **Peak-End Rule** | Experiences are judged by their peak moment and their ending. Nail the happy path and completion state |
| **Zeigarnik Effect** | Incomplete tasks stick in memory. Use progress indicators to leverage this (and reduce anxiety) |
| **Goal-Gradient Effect** | Motivation increases near the goal. Show progress, especially in multi-step flows |

### Interaction & Performance

| Law | Rule |
|-----|------|
| **Fitts's Law** | Bigger + closer targets = faster clicks. Make primary actions large and reachable |
| **Doherty Threshold** | Response times under 400ms feel instant. Anything slower needs a loading indicator |
| **Flow** | Don't interrupt the user's flow with unnecessary modals, confirmations, or redirects |
| **Paradox of the Active User** | Users don't read instructions — they act immediately. Make the UI self-explanatory |

### Trust & Familiarity

| Law | Rule |
|-----|------|
| **Jakob's Law** | Users expect your site to work like the sites they already know. Follow platform conventions |
| **Aesthetic-Usability Effect** | Beautiful design is perceived as more usable. Visual polish builds trust |
| **Postel's Law** | Be liberal in what you accept from users, strict in what you output. Tolerate input variations |
| **Mental Model** | Match the UI to how users think the system works, not how it actually works |
| **Occam's Razor** | Among solutions that work equally well, pick the simplest one |
| **Pareto Principle** | 80% of users use 20% of features. Optimize for the common paths |

<example>
// Good: Hick's Law — progressive disclosure, one decision at a time
<WizardStep title="Choose plan">
  <PlanCard plan="starter" />
  <PlanCard plan="pro" />
</WizardStep>

// Bad: all options dumped at once
<Form>
  <PlanSelector /><BillingFields /><TeamSettings /><IntegrationConfig />
</Form>
</example>

<example>
// Good: Fitts's Law — primary action is large and prominent
<Button size="lg" variant="primary">Save changes</Button>
<Button size="sm" variant="ghost">Cancel</Button>

// Bad: equal-weight actions, user has to read both to decide
<Button>Save changes</Button>
<Button>Cancel</Button>
</example>

<example>
// Good: Goal-Gradient + Zeigarnik — show progress in multi-step flow
<ProgressBar current={3} total={5} />
<StepContent step={3} />

// Bad: no indication of progress or remaining steps
<StepContent step={3} />
</example>

---

## Decision Checklist

Before writing code, answer:

| Question | If no... |
|----------|----------|
| Does the project already have a convention for this? | Follow it. Stop here |
| Am I using the domain's exact terms? | Rename to match ubiquitous language |
| Does this need identity tracking? | Make it a value object, not an entity |
| Does this cross an aggregate boundary? | Use a domain event or ID reference |
| Is this organized by feature? | Move to a vertical slice (unless framework dictates otherwise) |
| Am I building something not yet needed? | Delete it (YAGNI) |
| Can this be shipped independently? | Break it into a smaller change |
| Does the UI minimize cognitive load? | Apply Hick's, Miller's, and chunking |
| Are primary actions obvious and reachable? | Apply Fitts's Law and Von Restorff |
| Does this match user expectations? | Apply Jakob's Law and mental models |
