Here you can find description for every folder in the project, including the **tests** structure.


# Main Application Package (`finflow/`)

---

## `app/`

* Implements the presentation layer of the application.
* Contains controllers that mediate between UI actions and domain services, enforcing the MVC-like architecture.
* Houses PyQt6 view classes and widgets responsible for user-facing interactions.

### `app/controllers/`

* Bridges the GUI and business logic layers.
* Receives signals/events from the UI and orchestrates domain services accordingly.
* Ensures views do not directly talk to infrastructure or database.

### `app/views/`

* Contains all PyQt6 GUI screens, widgets, dialogs, and layouts.
* Focuses solely on rendering, user interaction, and emitting signals.
* Free of business logic to maintain strong separation of concerns.

---

## `domain/`

* Represents the pure business logic and rules of the application.
* Contains model objects (DTOs, value objects, aggregates) independent from UI or database details.
* Includes service classes implementing budgeting, calculation, and workflow rules following SOLID principles.

### `domain/models/`

* Contains domain entities such as Month, ExpenseEntry, TransferEntry, Category, BudgetPlan, etc.
* Implements business invariants independent of database or UI concerns.
* Provides clean Python classes suitable for testing in isolation.

### `domain/services/`

* Implements application-level rules: saving transactions, calculating summaries, monthly budgets, etc.
* Coordinates domain models and repositories.
* Forms the “brains” of the application while remaining database-agnostic.

---

## `infrastructure/`

* Handles persistence, integrations, and all external-system interactions.
* Implements the concrete SQLAlchemy repositories and ORM mappings.
* Decouples domain logic from storage by adhering to repository interfaces.

### `infrastructure/db/`

* Provides database engine configuration, session management, and connection pooling.
* Responsible for the SQLAlchemy `SessionLocal` and context managers.
* Centralized location for DB lifecycle handling.

### `infrastructure/orm/`

**SQLAlchemy ORM declarative models representing the database tables.
Defines Expense, Month, Transfer, Category, and other persisted entities.
Maps cleanly to domain models while handling relationships and constraints.**

### `infrastructure/repository/`

* Implements the concrete SQLAlchemy repositories that save, load, query, and delete domain objects.
* Each repository conforms to an interface defined by domain services (e.g., BudgetRepository).
* Responsible for translating between ORM objects and pure domain models while isolating DB logic.

---

## `resources/`

* Stores static assets required by the user interface.
* Includes icons, QSS stylesheets, images, and other front-end resources.
* Keeps UI assets organized and separate from code.

### `resources/icons/`

* Holds SVG/PNG icons used throughout the PyQt6 interface.
* Improves UI polish and maintainability.
* Ideal for theme or style reuse.

### `resources/qss/`

* Contains Qt stylesheet files to style and theme the GUI.
* Allows for consistent and reusable UI theming across the application.
* Keeps visual styling decoupled from view logic.

---

## `config/`

* Centralized configuration management layer.
* Loads environment variables, DB URLs, and application constants.
* Ensures configuration is strongly typed and easily overridden for tests or production.

---

## `utils/`

* A collection of helper functions and small utility classes.
* Contains reusable formatting utilities, file exporters, validators, and shared tools.
* Avoids cluttering the domain or app layers with cross-cutting concerns.

---

## Root Level

### `pyproject.toml`

* Central Poetry configuration file containing project metadata, dependencies, build backend, and environment settings.
* Defines how FinFlow is installed, packaged, and run across all environments.

### `README.md`

* High-level overview of the FinFlow application.
* Serves as the first point of reference for new developers or contributors.

### `docker-compose.yml`

* Defines the PostgreSQL service and related volumes/networks.
* Allows the app to spin up a fully isolated database environment automatically.
* Used by `run_with_docker.py` and development workflows.

### `.gitignore`

Specifies which files and directories should not be tracked by Git.

## `.github/workflows/ci.yml`

* Automated CI pipeline powered by GitHub Actions.
* Runs Poetry installation, linting, typing, migrations, and all unit/integration tests.
* Ensures the codebase remains stable, typed, and production-ready with every commit or PR.

## `app.py`

* Primary entrypoint for launching FinFlow.
* Initializes controllers, services, DB connections, and the PyQt6 event loop.
* Acts as the central composition root for dependency injection.

## `run_with_docker.py`

* Automatically starts PostgreSQL via Docker Compose when the app launches.
* Waits for DB readiness, injects the DB URL, and gracefully shuts down containers on exit.
* Creates a frictionless developer and end-user experience.

---

### `alembic/`

* Contains database migrations and version history.
* Tracks structural changes to the database schema over time.
* Ensures stable upgrades/downgrades across development and production environments.

---

## `docs/`

* Contains project-level documentation and developer guides.
* Used for architecture notes, layout explanations, onboarding, and technical decisions.
* Helps maintain long-term clarity and reduces knowledge silos within the team.

---

# Tests Folder

```
tests/
├── conftest.py
├── unit/
├── integration/
├── sanity/
└── ui/
```

### `tests/`

* Top-level testing suite for all layers of the system.
* Organized into unit, integration, UI, and sanity tests for maintainability.
* Ensures correctness, stability, and architectural integrity.

### `conftest.py`

* Provides pytest fixtures such as temporary DB setup, session factories, mock repositories, and app bootstrapping.
* Central place for reusable test utilities.

### `unit/`

* Pure unit tests for domain logic and services.
* Fast and isolated — no DB or PyQt6 dependencies required.
* Validates core business rules and policies.

### `integration/`

* Tests the behavior of repositories, ORM models, and migrations against a real PostgreSQL instance.
* Ensures SQLAlchemy mappings and database constraints behave as expected.

### `sanity/`

* Smoke tests to verify the build, environment, and minimal runtime behavior.
* Useful as a quick validation during CI or before releases.

### `ui/`

* Tests controllers and presenters using mocked PyQt6 views.
* Ensures UI event flow works correctly without requiring GUI rendering.


