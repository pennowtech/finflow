This guide shows you how to work *effortlessly* with **Docker**, **PostgreSQL**, and your **FinFlow** app (PyQt6 + SQLAlchemy + Poetry).

- [1. Overview](#1-overview)
- [2. Files Involved](#2-files-involved)
- [3. First-Time Setup](#3-first-time-setup)
  - [3.1 Install Dependencies](#31-install-dependencies)
- [4. Running PostgreSQL with Docker](#4-running-postgresql-with-docker)
  - [4.1 Start the Database (manually)](#41-start-the-database-manually)
  - [4.2 Stop the Database](#42-stop-the-database)
- [5. Using `run_with_docker.py` (recommended way)](#5-using-run_with_dockerpy-recommended-way)
- [6. Connecting with `psql`](#6-connecting-with-psql)
  - [6.1 Using Docker `psql` from Host](#61-using-docker-psql-from-host)
  - [6.2 Using Local `psql` Client](#62-using-local-psql-client)
- [8. Troubleshooting](#8-troubleshooting)
- [9. Quick Command Cheatsheet](#9-quick-command-cheatsheet)

## 1. Overview

In this project:

- PostgreSQL runs in a **Docker container** via `docker-compose.yml`.
- The app connects using `DATABASE_URL` (SQLAlchemy).
- `run_with_docker.py` can:
  - Start the DB container
  - Wait until it’s ready
  - Launch the PyQt6 app
  - Shut the container down when you close the app

You get a reproducible, clean local environment with minimal manual setup.

---

## 2. Files Involved

Key files related to Docker/DB:

- `.env` (placed in the same directory as your Compose file or specified explicitly)
- `docker-compose.yml`  
- `finflow/run_with_docker.py`  
- `finflow/config/settings.py` (holds `DATABASE_URL`)  

`.env` file contains information related to PostgreSql DB:
```
POSTGRES_USER=budgetuser
POSTGRES_PASSWORD=changeme
POSTGRES_DB=budgetdb
POSTGRES_PORT=5432
```

Your `docker-compose.yml` looks roughly like:

```yaml
version: '3.9'

services:
  db:
    image: postgres:16
    container_name: budget_db
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    ports:
      - "${POSTGRES_PORT}:5432"
    volumes:
      - dbdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER}"]
      interval: 5s
      timeout: 3s
      retries: 20
    restart: "no"

volumes:
  dbdata:
```

- The health check uses double-dollar `$$` to escape the `$` so that Compose passes it through correctly.

---

## 3. First-Time Setup

### 3.1 Install Dependencies

Make sure you have:

* Docker Desktop / Engine
* Docker Compose v2
* Python 3.11+
* Poetry


---

## 4. Running PostgreSQL with Docker

### 4.1 Start the Database (manually)

If you want to run DB manually, from project root:

```bash
docker compose up -d db
```

* `-d` runs it in the background.
* The DB will listen on `localhost:5432`.

To verify it’s running:

```bash
docker ps
```

You should see a container named `budget_db` (or whatever you set as `container_name`) is listed and in the running state.


**Use the Docker Compose healthcheck status:**
   Run `docker inspect --format='{{json .State.Health}}' budget_db` to see details of the healthcheck. It should show `"Status": "healthy"` once the container is ready.

**Connect to the database inside the container:**
   Run `docker exec -it budget_db psql -U $POSTGRES_USER -d $POSTGRES_DB` to open an interactive Postgres shell and run SQL commands like `\l` to list databases or simple queries, confirming connectivity and database availability.

**Connect externally via psql:**
   From your host or another machine, run:
   ```
   psql -h localhost -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB
   ```
   to verify the port mapping and access over the network.

**Verify health with `pg_isready`:**
   You can manually run inside the container or as a healthcheck test:
   ```
   docker exec budget_db pg_isready -U $POSTGRES_USER
   ```
   which returns server readiness.

These methods ensure your Postgres database is up, accepting connections, and working fully through Docker Compose environment variable configuration and port mapping.

### 4.2 Stop the Database

```bash
docker compose down
```

Note: This stops the container but keeps the data volume `dbdata`.

To **wipe everything** (including data):

```bash
docker compose down -v
```

or

```bash
docker volume rm finflow_dbdata
```

(depending on your project name / volume name).

---

## 5. Using `run_with_docker.py` (recommended way)

You can automate DB lifecycle with your runner script:

```bash
poetry run python -m finflow.run_with_docker
```

Typical behavior:

1. `docker compose up -d db`
2. Wait until PostgreSQL responds (`pg_isready` / connection test)
3. Launch PyQt6 app (`finflow.app.app` / `main_window.py`)
4. When the app exits, run `docker compose down`

This gives you a **one-command dev experience**.

---

## 6. Connecting with `psql`

Sometimes you want to poke the DB directly.

### 6.1 Using Docker `psql` from Host

```bash
docker exec -it budget_db psql -U <POSTGRES_USER> -d <POSTGRES_DB>
```

Then you can run SQL:

```sql
\dt          -- list tables
SELECT * FROM months;
\q           -- quit
```

### 6.2 Using Local `psql` Client

If you have `psql` installed locally:

```bash
psql -h localhost -p 5432 -U <POSTGRES_USER> -d <POSTGRES_DB>
```

Password: whatever you set in `POSTGRES_PASSWORD` (`changeme` in our example).

---

## 8. Troubleshooting

**App says it can’t connect to DB**

* Check if container is running: `docker ps`
* Try: `psql -h localhost -U <POSTGRES_USER> -d <POSTGRES_DB>`
* Verify `DATABASE_URL` matches your Docker env settings.

**Port already in use (5432)**

  Another Postgres is running locally.

  * Stop local service (e.g., `sudo service postgresql stop`)
  * OR change the host port mapping in `.env`, e.g.:

    ```yaml
    POSTGRES_PORT=5433
    ```

    This uses `:5433`.

---

## 9. Quick Command Cheatsheet

```bash
# Start DB only
docker compose up -d db

# Stop DB
docker compose down

# Start DB + App (auto managed)
poetry run python -m finflow.run_with_docker

# Connect to DB via Docker
docker exec -it budget_db psql -U <POSTGRES_USER> -d <POSTGRES_DB>

# Export Database Dump
docker exec budget_db pg_dump -U budgetuser budgetdb > backup.sql

# Restore Database Dump
cat backup.sql | docker exec -i budget_db psql -U budgetuser -d budgetdb

# Rebuild project from scratch (full reset)
docker compose down -v
docker compose up --build -d

# See running containers
docker ps

# Remove all stopped containers
docker container prune

```

