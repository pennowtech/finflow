# ADR-003: ORM Library — SQLAlchemy 2.0

## Status
Accepted

### Context
We need:

* Cross-platform ORM
* Strong typing
* Declarative modeling
* Support for PostgreSQL & Alembic migrations

### Decision
Use **SQLAlchemy ORM 2.0** with:

* Declarative Mapping
* Async-ready (future-proof)
* Session context managers
* Typed models

### Consequences
* Clean repository pattern
* Full compatibility with Alembic
* Clear separation of domain vs ORM models