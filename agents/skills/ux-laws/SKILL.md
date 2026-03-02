---
name: ux-laws
description: "Must use when building or reviewing user-facing interfaces. TRIGGER when: creating UI components, reviewing UX, designing flows, or laying out screens. Applies Laws of UX (Hick's, Fitts's, Miller's, Jakob's, etc.) to ensure usable, intuitive interfaces."
allowed-tools: Read, Grep, Glob, Edit, Write
model: sonnet
---

# UX Laws

Practical UX laws for building user-facing interfaces. Based on [Laws of UX](https://lawsofux.com/).

## When to use

- Building or modifying UI components
- Reviewing user-facing interfaces
- Designing multi-step flows, forms, or navigation
- Any PR or code review involving UI/UX decisions

## When NOT to use

- Pure backend or API-only code
- DevOps, CI/CD, infrastructure
- Design system audits against external checklists (use `web-design-guidelines`)

## Precedence

**Project design systems and component libraries always take priority.** These laws complement — never override — existing design tokens, spacing scales, or component APIs.

---

## Cognitive Load & Complexity

| Law                | Rule                                                                                 |
| ------------------ | ------------------------------------------------------------------------------------ |
| **Miller's Law**   | Keep groups to 7±2 items. Chunk information into digestible clusters                 |
| **Hick's Law**     | Fewer choices = faster decisions. Reduce options at each step                        |
| **Cognitive Load** | Minimize mental effort. One primary action per screen                                |
| **Tesler's Law**   | Complexity cannot be destroyed, only moved. Push it to the system, not the user      |
| **Chunking**       | Group related information into meaningful units (nav items, form sections, settings) |

## Perception & Attention

| Law                              | Rule                                                                                         |
| -------------------------------- | -------------------------------------------------------------------------------------------- |
| **Law of Prägnanz**              | People interpret complex shapes as the simplest form possible. Keep UI clean and unambiguous |
| **Law of Proximity**             | Place related elements close together. Whitespace creates grouping                           |
| **Law of Similarity**            | Visually similar elements are perceived as related. Consistent styling = clear relationships |
| **Law of Common Region**         | Elements in a shared boundary (card, box, section) feel grouped                              |
| **Law of Uniform Connectedness** | Lines or shared background connect elements more strongly than proximity alone               |
| **Von Restorff Effect**          | The distinctive item gets remembered. Use contrast for CTAs and key information              |
| **Selective Attention**          | Users focus on what's relevant to their goal. Don't compete for attention with decoration    |

## Behavior & Memory

| Law                        | Rule                                                                                                   |
| -------------------------- | ------------------------------------------------------------------------------------------------------ |
| **Serial Position Effect** | Users remember first and last items best. Put critical actions at the start or end                     |
| **Peak-End Rule**          | Experiences are judged by their peak moment and their ending. Nail the happy path and completion state |
| **Zeigarnik Effect**       | Incomplete tasks stick in memory. Use progress indicators to leverage this (and reduce anxiety)        |
| **Goal-Gradient Effect**   | Motivation increases near the goal. Show progress, especially in multi-step flows                      |

## Interaction & Performance

| Law                            | Rule                                                                                 |
| ------------------------------ | ------------------------------------------------------------------------------------ |
| **Fitts's Law**                | Bigger + closer targets = faster clicks. Make primary actions large and reachable    |
| **Doherty Threshold**          | Response times under 400ms feel instant. Anything slower needs a loading indicator   |
| **Flow**                       | Don't interrupt the user's flow with unnecessary modals, confirmations, or redirects |
| **Paradox of the Active User** | Users don't read instructions — they act immediately. Make the UI self-explanatory   |

## Trust & Familiarity

| Law                            | Rule                                                                                           |
| ------------------------------ | ---------------------------------------------------------------------------------------------- |
| **Jakob's Law**                | Users expect your site to work like the sites they already know. Follow platform conventions   |
| **Aesthetic-Usability Effect** | Beautiful design is perceived as more usable. Visual polish builds trust                       |
| **Postel's Law**               | Be liberal in what you accept from users, strict in what you output. Tolerate input variations |
| **Mental Model**               | Match the UI to how users think the system works, not how it actually works                    |
| **Occam's Razor**              | Among solutions that work equally well, pick the simplest one                                  |
| **Pareto Principle**           | 80% of users use 20% of features. Optimize for the common paths                                |

---

## Examples

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

## Quick Checklist

| Question                                       | If no...                                   |
| ---------------------------------------------- | ------------------------------------------ |
| Does the UI minimize cognitive load?           | Apply Hick's, Miller's, and chunking       |
| Are primary actions obvious and reachable?     | Apply Fitts's Law and Von Restorff         |
| Does this match user expectations?             | Apply Jakob's Law and mental models        |
| Is progress visible in multi-step flows?       | Apply Goal-Gradient and Zeigarnik          |
| Are response times under 400ms or loading shown? | Apply Doherty Threshold                  |
