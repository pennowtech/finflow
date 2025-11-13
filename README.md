
# 💸 FinFlow — Personal Finance Dashboard

A **modern, stress-free budget and abundance dashboard** built with **PyQt6**, **SQLAlchemy 2.0**, and **PostgreSQL** — running seamlessly via **Docker Compose**.

## 🌟 Features
- Track income, expenses, and goals with an intuitive GUI.
- Auto-starting PostgreSQL container (no manual DB setup).
- Charts for expenses and budget allocation (Matplotlib).
- Import/Export (CSV, JSON).
- Modular SOLID architecture with SQLAlchemy ORM.
- Cross-platform (macOS, Windows, Linux).

## 🚀 Quick Start

### Prerequisites
- Docker + Docker Compose v2
- Python 3.11+
- Virtualenv or Poetry

### Setup
```bash
git clone https://github.com/yourname/finflow.git
cd finflow
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
python run_with_docker.py
```

### Stopping

When you close the app, Docker containers shut down automatically.
Data persists in the `dbdata` Docker volume.

## 📊 Tech Stack

* **Frontend:** PyQt6 + Matplotlib
* **Backend:** SQLAlchemy 2.0 ORM
* **Database:** PostgreSQL 16
* **DevOps:** Docker Compose
* **Testing:** pytest

## 📈 Future Enhancements

* Cloud sync via Supabase
* Multi-user accounts
* Mobile-responsive UI (Qt for Android)
* AI-based expense categorization

---

### How To Run

1. Clone the repo.
2. Install dependencies with:
```bash
   pip install -r requirements-dev.txt
````

3. Use `docker compose up -d db` to start PostgreSQL.
4. Run migrations: `alembic upgrade head`
5. Run the app: `python -m budget_app.ui_main`

## 🧪 Testing

* Run all tests:

  ```bash
  pytest -v
  ```
* Lint with `ruff` or `flake8`
* Type-check with `mypy`

## 🧱 Code Style

* Follow **PEP8** and **SOLID principles**
* Use **SQLAlchemy ORM models**
* Commit messages use **Conventional Commits**, e.g.:

  * `feat(ui): add export to JSON`
  * `fix(db): resolve duplicate key issue`


