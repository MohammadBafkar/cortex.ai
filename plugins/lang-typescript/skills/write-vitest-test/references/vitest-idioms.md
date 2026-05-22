# Vitest idiom reference

Quick reference for common vitest patterns used by `lang-typescript.write-vitest-test`.

## Parametrized cases

Use `it.each` (not multiple `it` blocks) when only inputs vary:

```ts
it.each([
  [1, 2, 3],
  [0, 0, 0],
  [-1, 1, 0],
])("add(%i, %i) → %i", (a, b, expected) => {
  expect(add(a, b)).toBe(expected);
});
```

## Module mocks

Hoisted before imports — `vi.mock` is moved to the top of the file by vitest's
transform. To capture the original for partial mocks:

```ts
vi.mock("./db", async () => {
  const actual = await vi.importActual<typeof import("./db")>("./db");
  return { ...actual, queryUsers: vi.fn().mockResolvedValue([]) };
});
```

## Async assertions

When an assertion lives inside a `.then()` or promise callback, surrounding the
test with `expect.assertions(n)` makes silent skips loud:

```ts
it("resolves with the user", async () => {
  expect.assertions(1);
  return getUser(1).then((u) => {
    expect(u.id).toBe(1);
  });
});
```

Or, simpler, `await` the promise directly.

## Fake timers

```ts
beforeEach(() => vi.useFakeTimers());
afterEach(() => vi.useRealTimers());

it("debounces", () => {
  const fn = vi.fn();
  const debounced = debounce(fn, 100);
  debounced(); debounced();
  vi.advanceTimersByTime(100);
  expect(fn).toHaveBeenCalledTimes(1);
});
```

## Inline snapshots

Prefer over file-based snapshots when the value is small and stable — keeps
test + expectation co-located:

```ts
expect(parseQuery("a=1&b=2")).toMatchInlineSnapshot(`
  {
    "a": "1",
    "b": "2",
  }
`);
```

## What NOT to do

- `jest.fn()` / `jest.mock()` — vitest projects use `vi.*`.
- `it.skip("…")` with no reason — name the unmet precondition or remove the test.
- `expect(value as Foo)` — type assertions don't test runtime shape; use a guard.
- `// @ts-ignore` in tests — fix the type instead; tests are the wrong place to hide them.
