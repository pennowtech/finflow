# ⚙️ FinFlow — Setup & Run Guide

This document provides detailed, step-by-step instructions to set up, run, and maintain the **FinFlow Budget Dashboard** using **Poetry**, **Docker Compose**, and **PostgreSQL**.

## 🧱 1. Prerequisites

Before starting, ensure you have the following installed:

| Tool | Version | Purpose |
|------|----------|----------|
| 🐍 **Python** | 3.11+ | Core runtime |
| 📦 **Poetry** | 1.8+ | Dependency and environment manager |
| 🐋 **Docker Desktop / Engine** | 24+ | Database container |
| 🧩 **Docker Compose (v2)** | 2.20+ | Container orchestration |
| 🖼 **Git** | latest | Version control |

---

## 📂 2. Clone the Repository

```bash
git clone https://github.com/yourname/finflow.git
cd finflow
```

---

## 📦 3. Setup the Environment

### Step 1 — Create a Poetry Environment

Poetry will automatically create and manage a virtual environment.

```bash
poetry install
```

> This installs all dependencies from `pyproject.toml`.

### Step 2 — Activate the Environment

```bash
poetry shell
```

You should now see a `(finflow)` prefix in your terminal.

---

## 🧰 4. Environment Variables

Create a `.env` file in the project root (used by the app and Docker):

```bash
cp .env.example .env
```

Edit it with your desired configuration:

```dotenv
# Database
POSTGRES_USER=budgetuser
POSTGRES_PASSWORD=changeme
POSTGRES_DB=budgetdb
POSTGRES_PORT=5432
DATABASE_URL=postgresql+psycopg2://budgetuser:changeme@localhost:5432/budgetdb
```

---

## 🐳 5. Database Setup (Docker Compose)

### Start PostgreSQL

```bash
docker compose up -d
```

This will:

* Start a `postgres:16` container named `budget_db`
* Expose port `5432`
* Persist data in the `dbdata` volume

Check logs:

```bash
docker compose logs -f
```

Stop containers:

```bash
docker compose down
```

---

## 🗃️ 6. Database Schema (SQLAlchemy + Alembic)

### Initialize Alembic (if not done)

```bash
alembic init alembic
```

In `alembic/env.py`:

```python
from budget_app.models import Base
target_metadata = Base.metadata
```

### Generate migration

```bash
alembic revision --autogenerate -m "init database"
```

### Apply migration

```bash
alembic upgrade head
```

---

## 🧩 7. Run the App

### Option 1 — Run via Poetry directly

```bash
poetry run python budget_app/run_with_docker.py
```

This script will:

1. Launch PostgreSQL (via Docker Compose)
2. Wait until it's ready
3. Run the PyQt6 application (`ui_main.py`)
4. Stop Docker containers when you close the app

### Option 2 — Run without Docker (manual DB)

If you already have a PostgreSQL instance running:

```bash
export DATABASE_URL=postgresql+psycopg2://budgetuser:changeme@localhost:5432/budgetdb
poetry run python -m budget_app.ui_main
```

## 🧪 8. Run Tests

All tests use **pytest**.

```bash
poetry run pytest -v
```

---

## 🎨 9. Development Tools

| Tool    | Command                           | Purpose     |
| ------- | --------------------------------- | ----------- |
| Black   | `poetry run black .`              | Format code |
| Ruff    | `poetry run ruff check .`         | Lint code   |
| Mypy    | `poetry run mypy budget_app/`     | Type check  |
| Alembic | `poetry run alembic upgrade head` | Migrate DB  |

---

## 🧰 10. Useful Commands

### Update dependencies

```bash
poetry update
```

### Add new dependency

```bash
poetry add <package-name>
```

### Add dev dependency

```bash
poetry add --group dev pytest
```

### Export requirements.txt (for Docker)

```bash
poetry export -f requirements.txt --output requirements.txt
```

---

## 🧾 11. Project Commands Summary

| Task                 | Command                                                 |
| -------------------- | ------------------------------------------------------- |
| 🏗 Setup Environment | `poetry install`                                        |
| 🐳 Start DB          | `docker compose up -d`                                  |
| 🧩 Run App           | `poetry run python budget_app/run_with_docker.py`       |
| 🧪 Run Tests         | `poetry run pytest`                                     |
| 🧹 Format Code       | `poetry run black .`                                    |
| 🔍 Lint              | `poetry run ruff check .`                               |
| 🧱 Migrate DB        | `poetry run alembic upgrade head`                       |
| 💾 Export deps       | `poetry export -f requirements.txt -o requirements.txt` |

---

## 🔒 12. Stopping and Cleanup

Stop the app:

* Simply close the PyQt window or hit `Ctrl+C`.

Stop containers:

```bash
docker compose down
```

Remove all data (optional):

```bash
docker volume rm finflow_dbdata
```

---

## 🌿 13. Troubleshooting

| Issue                   | Solution                                                                 |
| ----------------------- | ------------------------------------------------------------------------ |
| Database not starting   | Ensure Docker is running, and port 5432 is free                          |
| `ModuleNotFoundError`   | Run inside Poetry shell or prefix with `poetry run`                      |
| App can't connect to DB | Check `.env` → `DATABASE_URL` correctness                                |
| GUI freezes on startup  | Ensure `run_with_docker.py` uses `async=False` and DB ready check passes |

---

## 🧠 14. Maintenance Tips

* Regularly run `poetry update` to keep dependencies secure.
* Backup your `dbdata` volume monthly.
* Tag releases in Git using semantic versioning (`v1.0.0`, `v1.1.0`, etc.).
* Document schema changes via Alembic migrations.

---

**Author:** Sukhdeep Singh
**License:** MIT
**Last Updated:** 2025-11-12

```