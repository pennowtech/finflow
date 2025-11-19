# ADR-004: Orchestrate DB Lifecycle with `run_with_docker.py`**

### Status: 
Accepted

### Context
End-user machines must:

* Start DB automatically
* Stop DB when app closes
* Avoid manual Docker commands

### Decision
Bundling a **Python supervisor script**:
`finflow/run_with_docker.py`

* Starts Docker Compose
* Waits for DB health
* Launches PyQt6 app
* Cleans up containers on exit

### Consequences
* Zero-click DB lifecycle
* Cleaner UX
* Requires Docker Desktop running
