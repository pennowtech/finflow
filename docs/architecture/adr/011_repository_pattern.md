# ADR 8 — Implement Repository Pattern

### Status: 
Accepted

### Context
We must isolate:
* Domain logic
* Data access logic

### Decision
Implement repositories in:
`finflow/infrastructure/repositories/sql_repositories.py`

Each repository:
* Exposes CRUD operations
* Consumes SQLAlchemy sessions
* Returns domain DTOs, not ORM entities

### Consequences
* DB can be swapped (PostgreSQL → SQLite)
* Test suite unaffected by persistence layer