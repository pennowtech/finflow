# 🏗 FinFlow Architecture

This document discusses various aspects related to **architecture** for of **FinFlow** application — including **diagrams**, **layer descriptions**, **domain model**, **runtime flows**, **deployment architecture**, **cross-cutting concepts**, **quality goals**, **risks**, various **ADRs** and more.

# 🏛️ **FinFlow – arc42 Architecture Documentation**

*Version 1.0 — 2025*

# 1. Introduction and Goals 

FinFlow is a modern, stress-free **personal finance and budgeting desktop application** built using:

* **PyQt6** (UI)
* **SQLAlchemy 2.0 ORM** (Persistence)
* **PostgreSQL (Dockerized)** (Database)
* **Poetry** (Package & environment manager)
* **SOLID-based layered architecture**
* **GitHub Actions CI**

The goal is to provide:

* A reliable, consistent budgeting tool
* Extensible domain logic
* Clear separation of concerns
* Maintainable, testable code
* Local-first storage with future cloud-sync capability

# 2. Architecture Constraints 

### Technical Constraints

* Python ≥ 3.11
* PyQt6 for GUI (mandatory)
* PostgreSQL for storage
* Docker Compose must orchestrate DB lifecycle
* SQLAlchemy ORM + Alembic migrations
* Poetry for dependency management
* GitHub Actions for CI
* Should run on Windows, macOS, Linux

### Organizational Constraints

* Code must follow **SOLID principles**
* Domain logic must not depend on UI or infrastructure
* Repository/repo-pattern must encapsulate DB logic
* All modules must use absolute imports under package namespace `finflow.*`

# 3. System Scope and Context 

## 3.1 Overall System Architecture (C4 Level 1)

```mermaid
%%{init: {'theme': 'neutral', 'themeVariables': {
  'primaryColor': '#f2f2f2',
  'edgeLabelBackground':'#e6ffe6',
  'actorBorder':'#000000'
}}}%%
graph TD
UI[PyQt6 GUI]
Controller[Application Controller]
Service[Domain Services]
Repo[Repository Layer]
ORM[SQLAlchemy ORM Models]
DB[(PostgreSQL DB via Docker)]

UI --> Controller --> Service --> Repo --> ORM --> DB

FinFlow allows users to:

* Track income, expenses, transfers
* View charts for monthly allocations
* Export/import data
* Maintain a clean personal budget

## 3.2 Technical Context

```mermaid
%%{init: {'theme': 'neutral', 'themeVariables': {
  'primaryColor': '#f2f2f2',
  'edgeLabelBackground':'#e6ffe6',
  'actorBorder':'#000000'
}}}%%
flowchart LR
    user((User))

    subgraph Desktop["User Machine"]
        app["FinFlow Desktop App (PyQt6)"]
        subgraph finflow["FinFlow Layers"]
            ui["UI / Views (PyQt6)"]
            controller["Controllers"]
            domain["Domain Services"]
            infra["Infrastructure (ORM + Repos)"]
        end
    end

    db[("PostgreSQL (Docker Container)")]
    ci[GitHub Actions CI Pipeline]

    user --> app
    app --> ui
    ui --> controller
    controller --> domain
    domain --> infra
    infra --> db

    ci --> GitHubRepo
    ci --> db
```

# 4. Development View 

## 4.1. Layered Architecture Diagram

```mermaid
%%{init: {'theme': 'neutral', 'themeVariables': {
  'primaryColor': '#f2f2f2',
  'edgeLabelBackground':'#e6ffe6',
  'actorBorder':'#000000'
}}}%%
flowchart TB
    subgraph App["Application Layer (app/)"]
        views["Views (PyQt6)<br />finflow/app/views/main_window.py"]
        controllers["Controllers<br />finflow/app/controllers/app_controller.py"]
    end

    subgraph Domain["Domain Layer (domain/)"]
        d_models["Domain Models / DTOs<br />finflow/domain/models/"]
        services["Domain Services: BudgetService, etc.<br />finflow/domain/services/budget_service.py"]
    end

    subgraph Infra["Infrastructure Layer (infrastructure/)"]
        repos["Repositories (SqlMonthRepo, SqlExpenseRepo, ...)<br />finflow/infrastructure/repositories/sql_repositories.py"]
        orm["ORM Entities (Month, Expense, Transfer, ...)<br />finflow/infrastructure/orm/entities.py"]
        db["DB Session & Engine<br />finflow/infrastructure/db/session.py"]
    end

    subgraph External["External Systems"]
        pg[("PostgreSQL")]
    end

    views --> controllers
    controllers --> services
    services --> repos
    repos --> orm
    orm --> db
    db --> pg
```

## 4.2. Entity / Data Model Diagram (`entities.py`)

This shows various **entities** that are defined for `Month`, `Expense`, `Transfer`, `SavingsGoal`, and `NetWorth`; and how they relate to each other.

```mermaid
%%{init: {'theme': 'neutral', 'themeVariables': {
  'primaryColor': '#f2f2f2',
  'edgeLabelBackground':'#e6ffe6',
  'actorBorder':'#000000'
}}}%%
classDiagram
    class Month {
        +int id
        +int year
        +int month
        +Decimal income
        +Decimal fixed_budget
        +Decimal emergency_budget
        +Decimal investments_budget
        +Decimal goals_budget
        +Decimal fun_budget
        +Decimal buffer_budget
        +List~Expense~ expenses
        +List~Transfer~ transfers
    }

    class Expense {
        +int id
        +int month_id
        +date dt
        +str category
        +Decimal amount
        +str note
    }

    class Transfer {
        +int id
        +int month_id
        +date dt
        +str kind  // 'emergency' | 'investment' | 'goal'
        +Decimal amount
        +str note
    }

    class SavingsGoal {
        +int id
        +str name
        +Decimal target
        +Decimal current
    }

    class NetWorth {
        +int id
        +date dt
        +Decimal assets
        +Decimal debts
    }

    Month "1" --> "*" Expense : has many
    Month "1" --> "*" Transfer : has many
```

## 4.3. Component Diagram Inside Backend (Services + Repos)

```mermaid
%%{init: {'theme': 'neutral', 'themeVariables': {
  'primaryColor': '#f2f2f2',
  'edgeLabelBackground':'#e6ffe6',
  'actorBorder':'#000000'
}}}%%
flowchart LR
    controller["AppController<br />(app/controllers/app_controller.py)"]
    service["BudgetService<br />(domain/services/budget_service.py)"]

    subgraph Repos["Repository Layer"]
        rMonth["MonthRepo<br />(SqlMonthRepo)"]
        rExpense["ExpenseRepo<br />(SqlExpenseRepo)"]
        rTransfer["TransferRepo<br />(SqlTransferRepo)"]
        rNet["NetWorthRepo<br />(SqlNetWorthRepo)"]
    end

    subgraph ORM["ORM Entities<br />(infrastructure/orm/entities.py)"]
        eMonth["Month"]
        eExpense["Expense"]
        eTransfer["Transfer"]
        eNet["NetWorth"]
    end

    db["Session / Engine<br />(infrastructure/db/session.py)"]
    pg[("PostgreSQL")]

    controller --> service
    service --> rMonth
    service --> rExpense
    service --> rTransfer
    service --> rNet

    rMonth --> eMonth
    rExpense --> eExpense
    rTransfer --> eTransfer
    rNet --> eNet

    eMonth --> db
    eExpense --> db
    eTransfer --> db
    eNet --> db

    db --> pg
```

## 4.4. Sequence Diagram — Add a New Expense

```mermaid
%%{init: {'theme': 'neutral', 'themeVariables': {
  'primaryColor': '#f2f2f2',
  'edgeLabelBackground':'#e6ffe6',
  'actorBorder':'#000000'
}}}%%
sequenceDiagram
    autonumber
    actor User
    participant View as MainWindow (PyQt6)
    participant Ctrl as AppController
    participant Svc as BudgetService
    participant Repo as ExpenseRepo
    participant ORM as Expense Entity
    participant DB as PostgreSQL

    User ->> View: Fill form + click "Add Expense"
    View ->> Ctrl: on_add_expense(date, category, amount, note)
    Ctrl ->> Svc: add_expense(month_id, dt, category, amount, note)
    Svc ->> Repo: add(month_id, dt, category, amount, note)
    Repo ->> ORM: create Expense(...)
    ORM ->> DB: INSERT INTO expenses (...)
    DB -->> ORM: row inserted (id)
    ORM -->> Repo: Expense instance
    Repo -->> Svc: success
    Svc -->> Ctrl: success
    Ctrl ->> View: update UI: refresh_expense_table()
    View ->> DB: (via service) reload list
    View -->> User: updated table with new row
```

## 4.5. Sequence Diagram — Import Expenses from CSV

```mermaid
%%{init: {'theme': 'neutral', 'themeVariables': {
  'primaryColor': '#f2f2f2',
  'edgeLabelBackground':'#e6ffe6',
  'actorBorder':'#000000'
}}}%%
sequenceDiagram
    autonumber
    actor User
    participant View as MainWindow
    participant Ctrl as AppController
    participant Svc as BudgetService
    participant Repo as ExpenseRepo
    participant DB as PostgreSQL
    participant FS as FileSystem

    User ->> View: Click "Import CSV"
    View ->> FS: Open file dialog (user selects file)
    View ->> Ctrl: import_expenses_from_csv(file_path)
    Ctrl ->> FS: Read CSV rows
    loop for each row
        Ctrl ->> Svc: add_expense(... parsed from row ...)
        Svc ->> Repo: add(...)
        Repo ->> DB: INSERT ...
    end
    Ctrl ->> View: reload_expenses()
    View ->> Svc: list_expenses(month_id)
    Svc ->> Repo: list(month_id)
    Repo ->> DB: SELECT ...
    DB -->> Repo: result set
    Repo -->> Svc: list[Expense]
    Svc -->> View: list[Expense]
    View -->> User: Table shows imported expenses
```

## 4.6. Sequence Diagram — Save or Update Month Budget

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant View as Settings View
    participant Ctrl as AppController
    participant Svc as BudgetService
    participant Repo as MonthRepo
    participant DB as PostgreSQL

    User ->> View: Enter year, month, budgets<br />Click "Save/Update Month"
    View ->> Ctrl: save_month(form_data)
    Ctrl ->> Svc: ensure_month(year, month, budgets...)
    Svc ->> Repo: upsert(year, month, budgets...)
    alt month exists
        Repo ->> DB: SELECT month
        DB -->> Repo: Month row
        Repo ->> DB: UPDATE months SET ...
    else new month
        Repo ->> DB: INSERT INTO months(...)
    end
    DB -->> Repo: success
    Repo -->> Svc: Month(id)
    Svc -->> Ctrl: month_id
    Ctrl ->> View: show_success(id), reload_months()
```

## 4.7. Sequence Diagram — Net Worth Snapshot

```mermaid
%%{init: {'theme': 'neutral', 'themeVariables': {
  'primaryColor': '#f2f2f2',
  'edgeLabelBackground':'#e6ffe6',
  'actorBorder':'#000000'
}}}%%
sequenceDiagram
    autonumber
    actor User
    participant View as NetWorth Tab
    participant Ctrl as AppController
    participant Svc as BudgetService
    participant Repo as NetWorthRepo
    participant DB as PostgreSQL

    User ->> View: Enter assets/debts + date<br />Click "Add Snapshot"
    View ->> Ctrl: add_networth(dt, assets, debts)
    Ctrl ->> Svc: add_networth(dt, assets, debts)
    Svc ->> Repo: add(dt, assets, debts)
    Repo ->> DB: INSERT INTO net_worth(dt, assets, debts)
    DB -->> Repo: success
    Svc -->> Ctrl: success
    Ctrl ->> View: reload_networth()
    View ->> Svc: list_networth()
    Svc ->> Repo: list()
    Repo ->> DB: SELECT * FROM net_worth ORDER BY dt DESC
    DB -->> Repo: rows
    Repo -->> Svc: list[NetWorth]
    Svc -->> View: list[NetWorth]
    View -->> User: refreshed table with updated net worth series
```

# 5. Deployment View

## 5.1 Local Deployment (Desktop)

```mermaid
%%{init: {'theme': 'neutral', 'themeVariables': {
  'primaryColor': '#f2f2f2',
  'edgeLabelBackground':'#e6ffe6',
  'actorBorder':'#000000'
}}}%%
graph TD
A[Host Machine]
B[FinFlow Python App]
C[(PostgreSQL Docker Container)]
A --> B
A --> C
B --> C
```

* App runs as a native Python process
* Database runs isolated inside a Docker container
* Both communicate over localhost port 5432

## 5.2. Deployment / Runtime Diagram (Local + Docker + CI)

```mermaid
%%{init: {'theme': 'neutral', 'themeVariables': {
  'primaryColor': '#f2f2f2',
  'edgeLabelBackground':'#e6ffe6',
  'actorBorder':'#000000'
}}}%%
flowchart TB
    subgraph DevMachine["Developer Machine"]
        appProc["Python Process: finflow/app.py<br />(PyQt6 GUI)"]
        runner["run_with_docker.py"]
        dockerCli["Docker CLI / Compose"]
    end

    subgraph DockerHost["Docker Engine"]
        dbContainer[("PostgreSQL Container<br />image: postgres:16<br />volume: dbdata")]
    end

    subgraph GitHub["GitHub Actions"]
        ciJob["CI Job<br />Ubuntu Runner"]
        ciPostgres[("PostgreSQL Service<br />for tests")]
    end

    runner --> dockerCli
    dockerCli --> dbContainer
    appProc --> dbContainer

    ciJob --> ciPostgres
    ciJob --> A[FinFlowTests: pytest, mypy, ruff]
```

## 5.3. Sequence Diagram — App Startup with Docker

```mermaid
%%{init: {'theme': 'neutral', 'themeVariables': {
  'primaryColor': '#f2f2f2',
  'edgeLabelBackground':'#e6ffe6',
  'actorBorder':'#000000'
}}}%%
sequenceDiagram
    autonumber
    actor User
    participant Runner as run_with_docker.py
    participant Docker as Docker Compose
    participant DB as Postgres Container
    participant App as PyQt6 App (app.py)

    User ->> Runner: python finflow/run_with_docker.py
    Runner ->> Docker: docker compose up -d db
    Docker ->> DB: Create & start postgres:16
    loop until healthy
        Runner ->> DB: pg_isready
        DB -->> Runner: ready / not ready
    end
    Runner ->> App: start PyQt6 app (app.py)<br />with DATABASE_URL env
    User ->> App: Uses UI
    App ->> DB: Queries via SQLAlchemy

    User ->> App: Close window
    App -->> Runner: process exits
    Runner ->> Docker: docker compose down
```

## 5.3. Sequence Diagram — CI Pipeline Run (GitHub Actions)

```mermaid
%%{init: {'theme': 'neutral', 'themeVariables': {
  'primaryColor': '#f2f2f2',
  'edgeLabelBackground':'#e6ffe6',
  'actorBorder':'#000000'
}}}%%
sequenceDiagram
    autonumber
    participant GH as GitHub
    participant CI as GitHub Actions Runner
    participant SvcPG as Postgres Service
    participant Poetry as Poetry CLI
    participant PyTest as pytest
    participant Alembic as Alembic

    GH ->> CI: push / PR to main
    CI ->> CI: checkout code
    CI ->> Poetry: install dependencies (poetry install --with dev)
    CI ->> SvcPG: start postgres:16 service
    CI ->> SvcPG: wait for pg_isready
    CI ->> Alembic: alembic upgrade head
    CI ->> Poetry: poetry run ruff check .
    CI ->> Poetry: poetry run mypy finflow/ (optional)
    CI ->> PyTest: poetry run pytest -v
    PyTest -->> CI: status (pass/fail)
    CI -->> GH: show status checks
```

# 6. Cross-cutting Concepts 

### 6.1 Configuration

* `settings.py` loads from `.env`
* Environment variables (DB_URL, DEBUG…)
* Use `python-dotenv`

### 6.2 Persistence

* SQLAlchemy ORM
* Repositories expose pure Python interfaces
* Alembic handles schema evolution

### 6.3 UI Design Principles

* Separation between view and logic
* Controllers only connect signals/slots
* No DB calls inside UI classes

### 6.4 Error Handling

* Domain services raise domain exceptions
* UI shows friendly dialogs
* Logging via Python `logging` module

### 6.5 Security

* No secrets committed in Git
* `.env` excluded via `.gitignore`
* Database only listens on localhost

# 7. Architecture Decisions (ADR) 

All architecture decisions record are stored under [adr/](adr) folder
These ADRs discusses all major architectural choices around:

* Backend
* Frontend
* CI
* DevOps
* Persistence
* Services
* Controllers
* App structure
* Build + Release

# 8. Quality Requirements 

The complete, detailed Quality Requirements specification is available in the separate document on [quality_requirements](8_quality_requirements.md)

# 9. Risks and Technical Debt

For the complete breakdown—including
 - identified risks,
 - probability & impact scoring,
 - mitigation strategies,
 - debt backlog, and
 - dependency-related risks

please refer to: [Technical risk catalog and debt register](9_risks_and_technical_debt.md)

# 10. Testing Strategy

FinFlow uses a layered testing approach (unit, integration, and GUI tests) to ensure reliability across the domain, infrastructure, and PyQt layers.
For full details, refer to: [testing_strategy.md](10_testing_strategy.md)

# 11. Glossary 

| Term | Meaning                      |
| ---- | ---------------------------- |
| DTO  | Data Transfer Object         |
| ORM  | Object Relational Mapper     |
| CRUD | Create, Read, Update, Delete |
| ADR  | Architecture Decision Record |
| CI   | Continuous Integration       |


