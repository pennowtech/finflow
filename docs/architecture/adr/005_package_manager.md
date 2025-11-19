# ADR-005: Use Poetry for Dependency & Environment Management**

### Status: Accepted

### Context

The project needs consistent build/release workflow & reproducible environments.

### Decision

Use **Poetry** for managing:

* Virtual environments
* Dependencies
* Packaging
* Version management

### Consequences

* Simple `poetry install` setup
* Automatic pyproject.toml
* Easy dependency upgrades
* Slight overhead learning Poetry syntaxPackage Manager — Poetry

## Status
Accepted

## Context
We need deterministic dependency management and dev/prod group separation.

## Decision
Use **Poetry** as dependency & environment manager.

## Consequences
- + Better version management
- + Lockfile ensures reproducibility