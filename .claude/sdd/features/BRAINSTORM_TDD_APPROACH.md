# BRAINSTORM: TDD Main Approach
**Feature:** TDD Main Approach
**Date:** 2026-04-01
**Branch:** plan-40
**Status:** Brainstorm complete — ready for Define phase

---

## 1. Discovery Questions

### Q1: Where should the test folder live?
**Answer: `tests/` at project root.**
Flat, conventional placement. Mirrors standard Python project layout. Avoids nesting inside `python/` which would complicate `sys.path` resolution and pytest discovery.

### Q2: How should integration tests be handled when Docker is down?
**Answer: Opt-in via `@pytest.mark.integration`.**
Integration tests are decorated with `@pytest.mark.integration` and skipped by default in `pytest -m "not integration"` runs. A developer with Docker running can opt in with `pytest -m integration`. This keeps the default run fast and infrastructure-free. The marker is registered in `pytest.ini` to avoid the PytestUnknownMarkWarning.

### Q3: Are there any YAGNI cuts from the original scope to reverse?
**Answer: None.**
All scope cuts confirmed as final. No reversals requested.

---

## 2. What is Being Tested

### 2a. `utils.py` — pure functions (unit)

| Function | What to test |
|----------|-------------|
| `create_path(*paths)` | Correct OS-joining of 0, 1, 2, 3+ path segments; handles empty string segment |
| `new_list_files(path, prefix)` | Returns only files matching prefix; returns `[]` on bad path; returns `[]` on non-matching prefix |

### 2b. `vars.py` — import safety (unit)

| Concern | What to test |
|---------|-------------|
| Import without `.env` | Module imports without raising; `db_secrets` keys are `None` or empty when `.env` absent |
| No side effects | Importing `vars` in test environment does not connect to DB or exit |

### 2c. `python/ingest_files.py` — pure functions (unit) + DB functions (integration)

| Function | Layer | What to test |
|----------|-------|-------------|
| `clean_text(texto)` | Unit | Strips accents (Portuguese: ã, ç, é, õ); replaces spaces and special chars with `_`; handles empty string; no-op on clean ASCII |
| `find_excel_files(root_folder)` | Unit (tmp_path) | Returns only `.xlsx` files; ignores non-xlsx; returns `[]` on empty dir |
| `insert_data(...)` | Integration (opt-in) | Inserts rows into live Postgres test table; verifies row count |
| `exec(...)` | Integration (opt-in) | Executes SQL against live Postgres; commits without error |
| `connect_to_postgres()` | Integration (opt-in) | Returns valid psycopg2 connection using test `.env` credentials |

### 2d. `gx_utils.py` — all 5 functions (unit with mocked GX context + integration opt-in)

| Function | Unit approach | Integration |
|----------|--------------|-------------|
| GX context builder | Mock `great_expectations.get_context()` | Opt-in: real GX context against test DB |
| Expectation suite creation | Mock suite builder; assert method calls | Opt-in: real suite persisted |
| Datasource registration | Mock datasource config; assert params | Opt-in: real datasource against test DB |
| Checkpoint creation | Mock checkpoint builder | Opt-in: real checkpoint run |
| Validation runner | Mock `checkpoint.run()`; assert result shape | Opt-in: real validation against seeded data |

---

## 3. Approaches Considered

### Approach A: pytest + pytest-mock, fixture-based [SELECTED]
**What:** Use `pytest` as the test runner with `pytest-mock` (`mocker` fixture) for unit-level mocking of psycopg2 and GX context. Fixtures in `conftest.py` provide shared setup. Integration tests are isolated in `tests/integration/` and gated by `@pytest.mark.integration`.

**Pros:**
- `pytest-mock`'s `mocker` fixture integrates cleanly with pytest's fixture lifecycle — no manual `patch.start()` / `patch.stop()` pairs.
- `tmp_path` built-in handles filesystem tests without cleanup boilerplate.
- Fail-fast with `pytest -x` gives immediate signal on first failure.
- Marker system (`@pytest.mark.integration`) is a native pytest primitive — zero additional libraries.
- `requirements-dev.txt` separation keeps production `requirements.txt` clean.

**Cons:**
- `pytest-mock` is an additional dependency (minor — it is the standard pytest mocking companion).
- GX mocking requires understanding GX's fluent builder API chain; mock setup can be verbose.

**Confidence:** 0.92
**Why selected:** Matches the existing codebase's Python 3.11.9 / psycopg2 / GE stack with no version conflicts. The fixture-based approach aligns with how `conftest.py` shared fixtures were already designed in the prior `BRAINSTORM_PYTEST_SUITE.md`. pytest-mock is the idiomatic complement to pytest and avoids the verbosity of raw `unittest.mock.patch` context managers.

---

### Approach B: unittest.mock only (no pytest-mock)
**What:** Use `unittest.mock.patch` as context managers or decorators. No additional test libraries beyond `pytest` itself.

**Pros:**
- Zero extra dependencies beyond `pytest`.
- Developers already familiar with `unittest.mock` from the standard library.

**Cons:**
- `patch` as a context manager inside a test function creates nested `with` blocks that reduce readability as test complexity grows.
- `patch` as a decorator stacks awkwardly when multiple patches are needed — argument order is reversed.
- No `mocker.spy` equivalent for non-destructive call inspection.

**Confidence:** 0.78
**Why not selected:** The verbosity cost compounds quickly for GX and psycopg2 mocking where 3-4 patches per test are common. `pytest-mock` solves exactly this problem with negligible overhead.

---

### Approach C: Factory-based fixtures with Faker data
**What:** Generate all test input data via `Faker` (already in `requirements.txt`) rather than hardcoded literals.

**Pros:**
- Realistic data surfaces edge cases that hardcoded strings miss.

**Cons:**
- Introduces non-determinism unless `Faker` is seeded in every fixture — adding setup friction.
- For functions like `clean_text`, the test value IS the specification (e.g., `"café" → "cafe"`). Randomising the input obscures intent.
- Overkill for the modules in scope here.

**Confidence:** 0.55
**Why not selected:** The target modules (`utils.py`, `vars.py`, `ingest_files.py`, `gx_utils.py`) have deterministic contracts best expressed with literal examples. Faker-based generation is better suited to the `gen/faker_generator.py` suite already covered in `BRAINSTORM_PYTEST_SUITE.md`.

---

## 4. Selected Approach Detail

**Approach A — pytest + pytest-mock, fixture-based**

### Test Structure

```
tests/
  conftest.py               # shared fixtures, marker registration hints
  unit/
    __init__.py
    test_utils.py           # create_path, new_list_files
    test_vars.py            # import safety, None-valued secrets
    test_ingest_clean_text.py   # clean_text, find_excel_files (tmp_path)
    test_gx_utils.py        # all 5 gx_utils functions, mocker-patched GX
  integration/
    __init__.py
    test_ingest_integration.py  # insert_data, exec, connect_to_postgres
    test_gx_integration.py      # real GX context, real checkpoint run
```

### conftest.py Responsibilities

- Register `integration` marker to suppress `PytestUnknownMarkWarning`.
- Provide `tmp_path`-based fixtures for filesystem tests (augments built-in `tmp_path` where shared setup is needed).
- Provide `mock_db_connection` fixture (mocker-based) for unit tests of DB-touching functions.
- Provide `mock_gx_context` fixture (mocker-based) for unit tests of `gx_utils.py`.
- Integration-only: provide `live_db_connection` fixture that skips if Postgres is unreachable.

### Marker Convention

```python
# tests/integration/test_ingest_integration.py
import pytest

@pytest.mark.integration
def test_insert_data_inserts_rows(live_db_connection):
    ...
```

Skipping when Docker is down is handled by `live_db_connection` fixture:

```python
@pytest.fixture
def live_db_connection():
    import psycopg2
    try:
        conn = psycopg2.connect(...)
        yield conn
        conn.close()
    except psycopg2.OperationalError:
        pytest.skip("Postgres not reachable — skipping integration test")
```

### Execution Commands

```bash
# Run all unit tests only (default, no Docker required)
pytest tests/unit/ -x

# Run integration tests (Docker must be running)
pytest tests/integration/ -m integration -x

# Run everything
pytest -x

# Run with verbose output
pytest -x -v
```

### pytest.ini (repo root)

```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
markers =
    integration: marks tests that require a live PostgreSQL connection (deselect with -m "not integration")
```

---

## 5. New Dev Dependencies

A new `requirements-dev.txt` is created at the repo root. It does NOT replace `requirements.txt`. Developers install both:

```
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

### `requirements-dev.txt` content

```
# Development and testing dependencies only
# Do NOT add these to requirements.txt — they are not needed at runtime

pytest==8.3.5
pytest-mock==3.14.0
pytest-cov==6.1.0
```

**Why these versions:**
- `pytest==8.3.5` — latest stable as of 2026-04; no conflicts with Python 3.11.9.
- `pytest-mock==3.14.0` — latest stable; thin wrapper around `unittest.mock`, no transitive conflicts.
- `pytest-cov==6.1.0` — optional at MVP but included to enable `--cov` flag from day one without a re-install.

`responses` (HTTP mock) is intentionally excluded here because `api_cb.py` is out of scope for this feature. It was captured in `BRAINSTORM_PYTEST_SUITE.md`.

---

## 6. Draft Requirements

### REQ-TDD-01: Test folder layout
A `tests/` directory must exist at the project root containing `unit/` and `integration/` subdirectories, each with an `__init__.py` to enable relative imports.

### REQ-TDD-02: conftest.py
A `tests/conftest.py` must register the `integration` marker and provide at minimum:
- `mock_db_connection` fixture (pytest-mock, function scope)
- `mock_gx_context` fixture (pytest-mock, function scope)
- `live_db_connection` fixture (function scope, skips if Postgres unreachable)

### REQ-TDD-03: Unit tests for utils.py
`tests/unit/test_utils.py` must cover `create_path` (boundary cases: 0, 1, 2, 3 segments; empty string segment) and `new_list_files` (matching prefix, non-matching prefix, missing directory path).

### REQ-TDD-04: Unit tests for vars.py import safety
`tests/unit/test_vars.py` must verify that importing `vars` in a no-`.env` environment does not raise an exception and that `db_secrets` values are `None` or empty string (not an exception).

### REQ-TDD-05: Unit tests for ingest_files pure functions
`tests/unit/test_ingest_clean_text.py` must cover `clean_text` (accented chars, spaces, special chars, empty string) and `find_excel_files` (matching only `.xlsx`, returning `[]` on empty directory) using `tmp_path`.

### REQ-TDD-06: Unit tests for gx_utils.py
`tests/unit/test_gx_utils.py` must cover all 5 functions in `gx_utils.py` using `mocker` to patch `great_expectations.get_context()` and the GX fluent builder chain. Each test must assert that the correct GX API methods were called with the expected arguments.

### REQ-TDD-07: Integration tests for ingest_files DB functions
`tests/integration/test_ingest_integration.py` must cover `insert_data`, `exec`, and `connect_to_postgres` decorated with `@pytest.mark.integration`. These tests skip automatically when Postgres is unreachable via the `live_db_connection` fixture.

### REQ-TDD-08: Integration tests for gx_utils.py
`tests/integration/test_gx_integration.py` must cover the real GX context, datasource, suite, and checkpoint creation against a live test database. All tests decorated with `@pytest.mark.integration`.

### REQ-TDD-09: Fail-fast configuration
All test runs described in developer documentation must use `pytest -x` as the default invocation to ensure the suite stops on the first failure.

### REQ-TDD-10: requirements-dev.txt
A `requirements-dev.txt` must be created at the repo root containing `pytest`, `pytest-mock`, and `pytest-cov` with pinned versions. It must NOT be merged into `requirements.txt`.

---

## 7. YAGNI — Removed Features

| Idea | Why Removed |
|------|-------------|
| Testing `python/etl_legacy.py` | Marked EOL in CLAUDE.md and file docstring. Investment in tests for a module being decommissioned is wasteful. Confirmed out of scope. |
| Testing `python/api_cb.py` | Already addressed in `BRAINSTORM_PYTEST_SUITE.md`. Duplicating it here would create conflicting specs. |
| Pandera schema validation | A separate data quality concern unrelated to the test infrastructure being established here. Would require a new library and a separate design session. |
| End-to-end pipeline tests (ingest → silver → gold) | Requires full Docker stack, seeded data, and GE validation run in sequence. This is a Phase 3 concern after unit and integration layers are stable. |
| CI/CD configuration (GitHub Actions workflow) | Out of scope per user confirmation. Pipeline automation is a separate roadmap item. |
| Coverage gates (`--cov-fail-under`) | Premature when starting from 0%. Establish a baseline after the first suite lands, then introduce a gate. |
| Property-based testing with `hypothesis` | Valuable eventually for `clean_text` and path functions, but adds a new library and learning curve. Not needed to reach meaningful coverage from zero. |
| Parameterized tests across all GX expectation types | Testing a representative subset of GX expectations covers the contract. Exhaustive parameterization adds maintenance cost with diminishing returns. |
| `pytest-faker` plugin | `faker` is already installed. `pytest-faker` adds a `faker` fixture but the `gen/faker_generator.py` tests (in the other brainstorm) handle Faker seeding directly. Not needed here. |

---

## 8. KB Domains for Define Phase

The define-agent should consult the following knowledge domains when writing the implementation specification:

1. **pytest fundamentals** — fixture scoping (`function` vs `session`), `conftest.py` shared fixture patterns, `tmp_path` built-in, `pytest.ini` marker registration, `pytest -x` fail-fast flag.

2. **pytest-mock** — `mocker.patch`, `mocker.patch.object`, `MagicMock` return value chaining, `mocker.spy` for call inspection without replacing behaviour.

3. **Great Expectations fluent API (GE 1.5.x)** — `get_context()`, `sources.add_postgres`, `add_expectation_suite`, `add_checkpoint`, `checkpoint.run()` — these are the call chains that `gx_utils.py` uses and that unit tests must mock accurately.

4. **psycopg2 connection mocking** — `conn.cursor().__enter__.return_value` chain, `cursor.execute`, `cursor.fetchall`, `conn.commit` — standard mock setup for unit-testing DB-calling Python functions.

5. **Python import isolation** — `sys.path.insert` in `conftest.py` vs `__init__.py` approach for importing modules from `python/` subdirectory; how `vars.py` `find_dotenv()` behaves when `.env` is absent.

6. **Integration test skip patterns** — `pytest.skip()` inside a fixture vs `pytest.importorskip()` vs `skipif`; how to detect Postgres availability cleanly (`psycopg2.OperationalError` catch in fixture).

7. **data-quality KB domain** — `great-expectations.md` pattern file in `.claude/kb/data-quality/patterns/` for GX context setup conventions used in this project.

---

## 9. Open Questions for Define Phase

- Does `gx_utils.py` already exist in the codebase, or does it need to be created as part of this feature? The file path must be confirmed before writing test imports.
- What are the exact 5 function signatures in `gx_utils.py`? The define-agent must read the file before specifying test cases to avoid mismatched argument assertions.
- Should `tests/unit/` and `tests/integration/` use `__init__.py` or rely on `rootdir`-based discovery? Confirm whether any existing `pyproject.toml` or `setup.cfg` exists that might affect pytest collection.
