---
name: ecoologic-test
description: "MUST use when writing, reviewing, or refactoring automated tests."
---

# Ecoologic Test

## Scope

This skill covers only these four rules:

1. Do not change the implementation of the subject under test just to make a test pass
  - except to temporarily break the code to verify the test failure
  - except to extract functions to test or mock, without changing its behaviour
2. Use black-box testing
3. Use spec format (module -> function -> context (optional) -> `it returns`)
4. In unit tests, ALWAYS describe actual code elements, NEVER humanize the code element
5. STOP and notify the user if the test is run in CI

## Good practices derived from these rules

- Let the description follow the real code structure
- Name the condition in the `when ...` block, not in the top-level subject
- Assert outcomes that a caller can observe
- If a test feels hard to write without poking internals, the test is probably violating black-box style
- If a test title cannot be mapped back to a symbol or endpoint, rename the title to the real code element
- The title should always reflect outside observable behaviour (`it "returns <x>"`, `it "throws <e>"`)
- NEVER test endpoints return 500 error, if you found a bug, raise the issue, and we'll fix it separately

## Review checklist

Use this checklist when writing or reviewing tests:

- [ ] The test does not require production-code behaviour changes to become testable
- [ ] The suite reads in spec format (module -> function -> context (optional) -> `it returns...`)
- [ ] Assertions target public behavior
- [ ] Unit test subjects use actual code element names
- [ ] Conditions are expressed with `when ...`
- [ ] Expected behavior is described concretely

### API test format

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
