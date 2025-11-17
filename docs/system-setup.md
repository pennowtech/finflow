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

## 3. Setup the Environment

### Step 1 — Install Poetry
```bash
curl -sSL https://install.python-poetry.org | python3 -
poetry --version
```
##### Optional (if want to specify a particular python version)
```bash
# pick your interpreter explicitly (choose one that passed the encodings test)
poetry env use /usr/bin/python3.11   # or /usr/bin/python3.10

# (optional but nice) keep the venv inside the project directory
poetry config virtualenvs.in-project true
```

### Step 2 — Enable tab completion for Bash or Zsh
##### if bash:
```bash
poetry completions bash >> ~/.bash_completion
```
##### if zsh:
```bash
mkdir $ZSH_CUSTOM/plugins/poetry
poetry completions zsh > $ZSH_CUSTOM/plugins/poetry/_poetry
```

You must then add poetry to your plugins array in `~/.zshrc`:

```bash
plugins(
	...
	poetrysour
	)
```

### Step 2 — Create a Poetry Environment

Poetry will automatically create and manage a virtual environment.
> Make sure that `pyproject.toml` exists

```bash
poetry env info

poetry install
```

> This installs all dependencies from `pyproject.toml`.


### Step 3 — Activate Virtual Environment

#### 1. Install the Legacy “Shell Plugin” (if you prefer `poetry shell`)

If you’d rather keep using the old behavior:

```bash
poetry self add poetry-plugin-shell
```

✅ This restores the legacy `shell` command exactly as in Poetry 1.x.
Now, you’ll be able to use following command to activate your virtual environment:

```bash
poetry shell
```

You should now see a (`finflow`) prefix in your terminal.

#### 2. Use the New Recommended Command (Official Way)

Instead of:

```bash
poetry shell
```

Now use:

```bash
poetry env activate
```

This activates the virtual environment managed by Poetry (similar to `poetry shell`, but native to v2).
You can also explicitly specify which environment to activate:

```bash
poetry env activate $(poetry env info --path)
```

To check where Poetry created your virtual environment:

```bash
poetry env info
```

Output example:

```
Virtualenv
Python:         3.11.7
Path:           /Users/you/Library/Caches/pypoetry/virtualenvs/finflow-py3.11
```

#### Quick Summary

| Task                    | Poetry < 2.0       | Poetry ≥ 2.0                          |
| ----------------------- | ------------------ | ------------------------------------- |
| Activate environment    | `poetry shell`     | `poetry env activate` *(recommended)* |
| Use legacy shell        | built-in           | `poetry self add poetry-plugin-shell` |
| Check venv path         | `poetry env info`  | same                                  |
| Run commands inside env | `poetry run <cmd>` | same                                  |


### Step 4 - Run FinFlow

To run your FinFlow app, there are three ways

- Run app inside Poetry env without activating:
    ```bash
    poetry run python finflow/app.py
    ```

- or, if you activated environment as per step 3:

    ```bash
    python finflow/app.py
    ```

---

## 4. Environment Variables

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

## 5. Database Setup (Docker Compose)

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

## 6. Database Schema (SQLAlchemy + Alembic)

**Assumptions:**

- SQLAlchemy models live in:
    `finflow/infrastructure/orm/entities.py` with `Base = DeclarativeBase`

- DB URL is in: `finflow/config/settings.py` as `CONFIG.database_url`

### Initialize Alembic (if not done)

- From _poetry shell_:
    ```bash
    alembic init alembic
    ```

- or from normal shell:
    ```bash
    poetry run alembic init alembic`
    ```
This creates:

- `alembic/` (`env.py`, `script.py.mako`, `versions/`)
- `alembic.ini` in the root

- Wire Alembic to your models. In `alembic/env.py`:
    ```python
    from logging.config import fileConfig
    from sqlalchemy import engine_from_config, pool
    from alembic import context

    from finflow.infrastructure.orm.entities import Base
    from finflow.config.settings import CONFIG

    config = context.config

    # Use our real DATABASE_URL instead of alembic.ini's sqlalchemy.url
    config.set_main_option("sqlalchemy.url", CONFIG.database_url)

    if config.config_file_name is not None:
        fileConfig(config.config_file_name)

    target_metadata = Base.metadata
    ```
Now Alembic knows:
- where to connect (your PostgreSQL)
- what schema to compare (your `Base.metadata`)

### Create the first migration
Make sure your models in entities.py are defined (Month, Expense, Transfer, etc.), then:
```bash
alembic revision --autogenerate -m "init database"
```
This writes a file in `alembic/versions/xxxx_init_database.py` with `upgrade()` and `downgrade()`.

Always:
- Check the generated file into Git
- Skim it to ensure it matches your intent

### Apply migration

```bash
alembic upgrade head
```
This creates all tables in your PostgreSQL DB.

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