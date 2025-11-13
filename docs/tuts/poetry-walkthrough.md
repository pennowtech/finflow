# Poetry Walk-Through Guide

This document explains how to **manage Python dependencies and environments** for the **FinFlow** project using **Poetry** — a modern dependency and packaging tool.  

> ⚙️ **Note:** System setup instructions (Poetry installation, Python, Docker, etc.) are covered in `docs/system-setup.md`.  
> This document assumes Poetry is already installed and configured on your machine.

---

## 🧩 Overview

**FinFlow** uses **Poetry** to handle:
- Environment management (no manual virtualenvs needed)
- Dependency versioning and locking (`pyproject.toml` & `poetry.lock`)
- Consistent reproducibility across local, CI, and Docker environments
- Easy package updates and dependency inspection

The goal is to ensure **a clean, reliable setup** for both developers and CI pipelines.

---

## 🚀 Basic Poetry Commands

| Purpose                   | Command                                                 | Description                                       |
| ------------------------- | ------------------------------------------------------- | ------------------------------------------------- |
| 🏗️ Create environment      | `poetry install`                                        | Installs all dependencies (from `pyproject.toml`) |
| 💻 Enter environment       | `poetry shell`                                          | Activates Poetry’s virtual environment            |
| 🧩 Add a dependency        | `poetry add <package>`                                  | Adds a new runtime dependency                     |
| 🧪 Add a dev dependency    | `poetry add --group dev <package>`                      | Adds for dev/test only                            |
| ❌ Remove dependency       | `poetry remove <package>`                               | Removes from both files                           |
| 📜 List installed packages | `poetry show`                                           | Displays versions and metadata                    |
| 🌳 View dependency tree    | `poetry show --tree`                                    | Shows full dependency hierarchy                   |
| 🔍 Check outdated packages | `poetry show --outdated`                                | Lists packages with new releases                  |
| 🔄 Update one/all          | `poetry update [<package>]`                             | Upgrades dependencies and lock file               |
| 🧱 Build package           | `poetry build`                                          | Creates wheel and sdist in `/dist`                |
| 🧰 Export for Docker       | `poetry export -f requirements.txt -o requirements.txt` | Exports deps for non-Poetry environments          |

---

### Find Outdated Packages

```bash
poetry show --outdated
```

Example output:

```
Name         Installed  Latest  Description
black        24.8.0     24.10.0  The uncompromising code formatter.
SQLAlchemy   2.0.35     2.0.36   Python SQL toolkit and ORM.
```

### Update Dependencies

* **Update all:**

  ```bash
  poetry update
  ```
* **Update specific:**

  ```bash
  poetry update SQLAlchemy
  ```
* **Include dev dependencies:**

  ```bash
  poetry update --with dev
  ```

* **Check Changes Before Applying:**
    Simulate the update to preview changes:

    ```bash
    poetry update --dry-run
    ```

---

## Adding New Packages

- **Add a new library (latest version):**

    ```bash
    poetry add requests
    ```

- **Add with version constraint:**

    ```bash
    poetry add "SQLAlchemy^2.0"
    ```

- **Add dev-only package:**

    ```bash
    poetry add --group dev pytest
    ```

---

## Poetry Environment Tips

- **Activate Virtual Environment**

    ```bash
    poetry shell
    ```

- **Run Command Inside Env Without Activating**

    ```bash
    poetry run python main.py
    ```

- **Where Is My Environment?**

    ```bash
    poetry env info
    ```

- **To remove the environment completely:**

    ```bash
    poetry env remove python
    ```

---

## Testing & CI Integration

- **GitHub Actions (see `.github/workflows/ci.yml`) uses:**

    ```yaml
    - run: poetry install --with dev
    - run: poetry run pytest -v
    ```

This ensures consistent dependency resolution and virtualenv handling inside CI.

---

## Updating Poetry Itself

- **Check Poetry version:**

    ```bash
    poetry --version
    ```

- **Update Poetry:**

    ```bash
    poetry self update
    ```

