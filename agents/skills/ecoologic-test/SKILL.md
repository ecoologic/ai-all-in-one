---
name: ecoologic-test
description: "Use when writing, reviewing, or refactoring automated tests. Applies four rules only: do not change production code to fit tests, use spec-style test structure, prefer black-box testing, and describe real code elements in test names."
---

# Ecoologic Test

Lean testing rules extracted from `ecoologic-code`, expanded only for test authoring and test review.

## Scope

Use this skill when:

- Writing new tests
- Refactoring existing tests
- Reviewing test quality
- Naming test suites and test cases

This skill covers only these four rules:

1. Do not change the implementation of the subject under test just to make a test pass
2. Use spec format
3. Use black-box testing
4. In unit tests, describe actual code elements

## Rule 0: Only test for CI

There's no point in testing code that is not executed in CI. If a test would not run in CI, don't write it.

## Rule 1: Preserve the subject under test

Do not modify production code to satisfy a test unless you are deliberately verifying that the test fails first. If you temporarily break the implementation to confirm the test is red, restore it before continuing.

The test must adapt to the real public behavior of the subject. Do not reshape the subject to make assertions easier.

### Good

- Write the test against the existing public API
- Adjust fixtures, inputs, or assertions
- Temporarily force a failure only to confirm the test is meaningful, then restore the original implementation

### Bad

- Adding test-only branches to production code
- Exposing internals only so the test can inspect them
- Renaming behavior in code because the test description was written poorly
- Rewriting working production logic to match a test's assumption

### Example

```typescript
// Good: assert via the public contract
describe('POST /users', () => {
  describe('when the payload is valid', () => {
    it('returns 201', async () => {
      const response = await request(app)
        .post('/users')
        .send(validPayload);

      expect(response.status).toBe(201);
    });
  });
});
```

```typescript
// Bad: changing production code just so a test can peek inside
// production
export const createUser = (input: CreateUserInput) => {
  const result = persistUser(input);

  return {
    result,
    // test-only leakage
    _debugPersistedPayload: input,
  };
};
```

## Rule 2: Always use spec format

Structure tests as behavior specifications. The suite should read like a precise statement of what the code element does under a condition.

Preferred pattern:

`describe class/module`
`describe method/function/endpoint`
`when condition`
`it returns/does ...`

Keep the language concrete and behavioral.

### Template

```text
describe <code element>
  describe <method, function, or endpoint>
    when <condition>
      it <expected behavior>
```

### Good

```typescript
describe('userForm', () => {
  describe('submit', () => {
    describe('when all required fields are valid', () => {
      it('returns success', async () => {
        // test
      });
    });
  });
});
```

```typescript
describe('POST /users', () => {
  describe('when the email already exists', () => {
    it('returns 409', async () => {
      // test
    });
  });
});
```

### Bad

```typescript
describe('user stuff', () => {
  it('works', () => {
    // vague
  });
});
```

```typescript
describe('creating a user', () => {
  it('should do the right thing', () => {
    // not spec format
  });
});
```

## Rule 3: Always use black-box testing

Test observable behavior, not implementation details.

Prefer:

- Inputs and outputs
- Returned values
- Visible state changes
- HTTP responses
- Rendered UI behavior
- Published side effects that are part of the contract

Avoid asserting:

- Private methods
- Internal helper calls unless that call is the public contract
- Temporary local variables
- Incidental implementation structure

### Good

```typescript
describe('calculateShippingCost', () => {
  describe('when the order total is above the free-shipping threshold', () => {
    it('returns 0', () => {
      expect(calculateShippingCost(largeOrder)).toBe(0);
    });
  });
});
```

### Bad

```typescript
describe('calculateShippingCost', () => {
  it('calls getThreshold with the premium flag', () => {
    const getThreshold = vi.spyOn(thresholds, 'getThreshold');

    calculateShippingCost(largeOrder);

    expect(getThreshold).toHaveBeenCalledWith('premium');
  });
});
```

The bad example couples the test to how the answer is computed instead of what the public result is.

## Rule 4: In unit tests, describe actual code elements

Use the real code element name in unit test descriptions.

Name the subject exactly as it exists in code:

- `userForm`
- `submit`
- `calculateShippingCost`
- `POST /users`

Do not replace real code elements with paraphrases:

- `the form for users`
- `submitting the form`
- `create a user`

This keeps tests searchable, unambiguous, and aligned with the code.

### Good

```typescript
describe('userForm', () => {
  describe('submit', () => {
    describe('when the email is invalid', () => {
      it('returns a validation error', async () => {
        // test
      });
    });
  });
});
```

```typescript
describe('POST /users', () => {
  describe('when the payload is invalid', () => {
    it('returns 422', async () => {
      // test
    });
  });
});
```

### Bad

```typescript
describe('the user form', () => {
  describe('when someone tries to submit it', () => {
    it('shows an error', async () => {
      // vague and not tied to a real code element
    });
  });
});
```

## Good practices derived from these rules

- Let the description follow the real code structure
- Name the condition in the `when ...` block, not in the top-level subject
- Assert outcomes that a caller can observe
- If a test feels hard to write without poking internals, the test is probably violating black-box style
- If a test title cannot be mapped back to a symbol or endpoint, rename the title to the real code element
- NEVER test endpoints return 500 error, if you found a bug, raise the issue, and we'll fix it separately

## Review checklist

Use this checklist when writing or reviewing tests:

- [ ] The test does not require production-code changes to become testable
- [ ] The suite reads in spec format
- [ ] Assertions target public behavior
- [ ] Unit test subjects use actual code element names
- [ ] Conditions are expressed with `when ...`
- [ ] Expected behavior is described concretely

## Quick examples

### Unit test

```typescript
describe('calculateShippingCost', () => {
  describe('when the order total is above the free-shipping threshold', () => {
    it('returns 0', () => {
      expect(calculateShippingCost(order)).toBe(0);
    });
  });
});
```

### API test

```typescript
describe('POST /users', () => {
  describe('when the email already exists', () => {
    it('returns 409', async () => {
      const response = await request(app)
        .post('/users')
        .send(existingEmailPayload);

      expect(response.status).toBe(409);
    });
  });
});
```

## Final reminder

A good test in this style reads like a spec for a real code element, verifies only observable behavior, and never pressures production code to become test-shaped.
