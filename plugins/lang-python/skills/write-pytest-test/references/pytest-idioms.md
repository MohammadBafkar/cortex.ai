# Pytest Idioms — Reference Card

Cited by `lang-python.write-pytest-test`. When in doubt, follow these patterns.

## Naming

```python
def test_add_returns_sum_for_positive_ints():
    assert add(2, 3) == 5

def test_add_raises_typeerror_for_string_arg():
    with pytest.raises(TypeError):
        add(2, "three")
```

Pattern: `test_<unit>_<scenario>_<expected>`. The pytest failure summary shows
the test name — make it carry the diagnostic.

## Fixtures

```python
@pytest.fixture
def in_memory_db():
    conn = sqlite3.connect(":memory:")
    conn.executescript(SCHEMA)
    yield conn
    conn.close()
```

Default `scope="function"`. Use `scope="module"` only when setup is
genuinely expensive AND tests can tolerate shared state.

## Parametrize

```python
@pytest.mark.parametrize(
    "input,expected",
    [
        (0, 0),
        (1, 1),
        (-1, 1),
        (100, 10000),
    ],
    ids=["zero", "one", "negative", "hundred"],
)
def test_square(input, expected):
    assert square(input) == expected
```

`ids=` makes failure output readable. Without it, the failure says
`test_square[0-0]` which is unhelpful.

## monkeypatch

```python
def test_reads_env(monkeypatch):
    monkeypatch.setenv("API_KEY", "test-key")
    assert client.from_env().key == "test-key"
```

Use for env vars, attribute patches, sys.path mutations — anything that needs
to be unwound after the test.

## tmp_path (NOT tempfile.mkdtemp())

```python
def test_writes_log(tmp_path):
    out = tmp_path / "out.log"
    write_log(out)
    assert out.exists()
```

`tmp_path` is auto-cleaned. `tempfile.mkdtemp()` is not.

## capsys / caplog

```python
def test_prints_banner(capsys):
    main()
    captured = capsys.readouterr()
    assert "Welcome" in captured.out

def test_logs_warning(caplog):
    with caplog.at_level(logging.WARNING):
        do_thing_that_warns()
    assert any("deprecated" in r.message for r in caplog.records)
```

## Anti-patterns to refuse

1. **Multiple unrelated assertions per test.** Split. The first failing
   assertion masks the rest.
2. **Shared mutable state between tests** (module-level lists, dicts).
   Each test must be independently runnable.
3. **`pytest.skip()` without a reason that names the unmet precondition.**
4. **Tests that import the module under test under a try/except** — that
   hides import errors as "no tests ran".
5. **`time.sleep()` in tests.** Use `freezegun` or `monkeypatch.setattr(time, "sleep", lambda _: None)`.
6. **Network calls without `responses` / `httpx_mock` / `vcrpy`.** Tests
   that hit the real network are flaky and slow.

## When pytest doesn't quite fit

- **Property-based:** add `hypothesis` and use `@given(...)`.
- **Async:** install `pytest-asyncio`; mark with `@pytest.mark.asyncio`.
- **Snapshot:** `syrupy` for deterministic snapshot comparisons.
- **Mutation:** `mutmut` (slower; runs only on demand via `quality.run-mutation-tests`).
