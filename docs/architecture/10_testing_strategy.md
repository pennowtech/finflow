# Test Plan

This document describes the test strategy, levels, tools, and responsibilities for the FinFlow application.

## 1. Objectives

- Ensure **functional correctness** of budgeting features.
- Protect **data integrity** across DB migrations and multiple releases.
- Validate **non-functional requirements** (quality scenarios).
- Provide high confidence in each change via **automated CI**.

## 2. Test Levels

### 2.1 Unit Tests

**Scope**
- Domain services (e.g. `budget_service.py`)
- Utility functions (`finflow/utils/helpers.py`)
- Repository behavior using in-memory or test Postgres DB

**Tools**
- `pytest`
- `mypy` for static types
- `ruff` for linting

**Examples**
- Adding expenses updates totals correctly.
- Transfers are grouped by kind (emergency/investment/goal).
- Formatting helpers (e.g. money formatting) behave as expected.

### 2.2 Integration Tests

**Scope**
- SQLAlchemy ORM + PostgreSQL
- Alembic migrations
- Repository methods (`sql_repositories.py`)

**Setup**
- Use a dedicated test database (`finflow_test`) spinning up via GitHub
  Actions service container (Postgres 16).
- Run migrations: `alembic upgrade head`.

**Examples**
- `Month` creation + linked `Expense` and `Transfer` persistence.
- Totals per month (`totals_for_month`) computed correctly.
- Import/export features with real DB.

### 2.3 System / UI Tests

**Scope**
- End-to-end flows from PyQt UI through domain into DB.

**Tools (optional but recommended)**
- `pytest-qt` for Qt widget testing.
- Manual test scripts for exploratory testing.

**Scenarios**
- User starts app, selects month, adds an expense; table and charts update.
- User adds emergency transfer; progress bars reflect new totals.
- CSV import and error reporting via dialogs.

**Notes**
- UI tests may be partially manual at first; gradually automated for critical flows.

### 2.4 Regression Tests

**Goal**
- Ensure that previously fixed bugs do not reappear.

**Approach**
- For every significant bug:
  - Add a **failing test** reproducing issue.
  - Fix the bug so the test passes.
  - Link test ID to issue in commit message/PR.

## 3. Test Environments

### 3.1 Local Developer Environment

- OS: Windows / macOS / Linux
- DB: PostgreSQL via Docker (`docker compose up -d`)
- Commands:

```bash
poetry install --with dev
docker compose up -d
export DATABASE_URL=postgresql+psycopg2://budgetuser:changeme@localhost:5432/budgetdb
alembic upgrade head
pytest -v
````

### 3.2 CI Environment (GitHub Actions)

* OS: `ubuntu-latest`
* Services: `postgres:16`
* Steps:

  * Install Python, Poetry
  * `poetry install --with dev`
  * Wait for Postgres
  * Run Alembic migrations (`alembic upgrade head`)
  * `ruff`, `mypy`, `pytest`
  * Optional: `poetry build`

## 4. Test Data

### 4.1 Synthetic Data

* Use factories or fixtures to generate:

  * Expenses for various categories (rent, groceries, entertainment)
  * Transfers of all types (emergency/investment/goal)
  * Net worth snapshots

### 4.2 Realistic Data Samples

* Provide anonymized example CSV files under `tests/data/`:

  * `sample_expenses_small.csv`
  * `sample_expenses_large.csv` (~10k rows for performance testing)

## 5. Test Case Categories

### 5.1 Functional

* Add/Edit/Delete Expense
* Add Transfers (emergency, investment, goal)
* Calculate monthly budgets and progress
* Import/Export CSV & JSON

### 5.2 Non-Functional

* **Performance**: Loading large datasets, rendering charts.
* **Robustness**: Behavior when DB is unavailable.
* **Usability (basic)**: App loads without overlapping widgets or broken layouts.

### 5.3 Security

* `.env` is not committed to repo.
* Database credentials configurable and not hard-coded.

## 6. Responsibilities

* **Maintainer / Lead Dev**
  * Approves test strategy changes
  * Ensures CI is green before releases

* **Contributors**
  * Add unit tests for new features
  * Add regression tests for bug fixes

## 7. Exit Criteria

A change (PR or release) is considered acceptable when:
* All unit and integration tests pass on CI.
* Linting (ruff) and type checking (mypy) are clean or known exceptions documented.
* Critical manual tests (smoke tests) are performed for UI changes:

  * App starts
  * Month can be selected/created
  * Expense can be added and visualized

## 8. Continuous Improvement

* Periodic review of flakiest tests.
* Increase test coverage for:

  * Domain services > 80%
  * Repositories > 70%
* Introduce coverage reporting tool (e.g. `coverage.py` + Codecov) later.

```

If you want, next step I can:

- Turn these into **separate `.md` files** mapped to your `docs/` structure, and
- Propose an `arc42-INDEX.md` that links all sections (1–12) so the whole architecture handbook is nicely navigable.
::contentReference[oaicite:0]{index=0}
```
