# ADR-002: Database Technology — PostgreSQL

## Status
Accepted

## Context
The app must:
* Run on all OS
* Require zero manual DB installation
* Offer reliability & ACID guarantees
* Work offline for local analysis

### Decision
Use **PostgreSQL running in a Docker container** via `docker-compose.yml`.
The file includes volume storage and health checks.

### Consequences
* Developer onboarding simplified
* Consistent database across environments
* Cleaner migration pipeline
* Requires Docker availability