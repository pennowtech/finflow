# ADR 14 — Use DTOs (Domain Models) Instead of ORM Entities

### Status:
Accepted

### Context
ORM models should never leave the infrastructure layer.

### Decision
Domain models (`domain/models/`) are **pure dataclasses**.
Repositories convert ORM → DTO.

### Consequences
* Domain stays framework-agnostic
* Cleaner testing
* Better architecture decoupling