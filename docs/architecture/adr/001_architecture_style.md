# ADR-001: Architecture Style — Layered + Hexagonal Hybrid

## Status
Accepted


## Context

The app requires:

* A clean separation between domain/business logic and UI
* Swappable infrastructures (e.g., PostgreSQL → SQLite for tests)
* Maintainability and SOLID compliance
* Reproducible testing without GUI or DB dependencies

## Decision

We adopt a **Hexagonal Architecture (a.k.a. Ports & Adapters)** layered as:

* **Domain Layer**
  (entities, models, business services)
* **Application Layer**
  (controllers coordinating domain + UI)
* **Infrastructure Layer**
  (ORM, repositories, DB sessions)
* **UI Layer (PyQt6)**
  (views, widgets)

## Consequences

* Domain is fully isolated from frameworks
* Easy to unit-test the domain
* Lower coupling between GUI & database
* Infrastructure can be swapped without app rewrite