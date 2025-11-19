# ADR 10 — Use a Controller Layer (MVC/MVP hybrid)

### Status: 
Accepted

### Context
Domain logic must never be triggered directly by UI objects.
We need a bridging layer.

### Decision
Create a **controller layer** that:
* Handles PyQt signal routing
* Calls domain services
* Updates views with DTOs
* Orchestrates repository operations

### Consequences
* UI stays "dumb" and testable
* Domain stays clean
* Better SOLID compliance