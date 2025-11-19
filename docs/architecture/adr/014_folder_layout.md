# ADR 15 — Folder Layout Based on Clean Architecture

### Status: 
Accepted

### Context
We need a scalable, maintainable structure.

### Decision
Use the following folder structure:

```
finflow/
  app/
  domain/
  infrastructure/
  utils/
  resources/
  config/
  tests/
```

### Consequences
* Clean separation of concerns
* Long-term stability
* Easy onboarding
