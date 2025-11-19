A quick, practical Alembic walkthrough tailored to our `finflow` project layout.

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
    from finflow.config.settings import settings

    config = context.config

    # Use our real DATABASE_URL instead of alembic.ini's sqlalchemy.url
    config.set_main_option("sqlalchemy.url", settings.database_url)

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

### Updating Your Database Schema with Alembic

Whenever you modify your SQLAlchemy ORM models (e.g., adding tables, columns, constraints):

#### Update your ORM models

Edit the schema inside:

```
finflow/infrastructure/orm/entities.py
```

#### Create a new migration revision

Alembic will auto-detect model changes and generate migration code:

```bash
poetry run alembic revision --autogenerate -m "Add savings_goal_table"
```

#### Apply the migration to the database

Bring your schema up to date:

```bash
poetry run alembic upgrade head
```

#### Roll back if needed

If something breaks, revert to the previous revision:

```bash
poetry run alembic downgrade -1
```

