# ADR-008: CI/CD — GitHub Actions

## Status
Accepted

## Context
We require:
* Automated tests
* Linting
* Build packaging

### Decision
Create a CI pipeline under:
`.github/workflows/ci.yml`

Pipeline includes:
* Python setup
* Poetry install
* Run PostgreSQL service
* Alembic migration
* Lint (Ruff)
* Type-check (Mypy)
* Tests (Pytest)

### Consequences
* Reliable PR validation
* Ensures code quality
* Transparent build state