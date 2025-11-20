## 1. `entities.py`?

* It is the file where we define all our **database tables** using **SQLAlchemy ORM**.
* It lets you work with **Python classes** instead of manually writing SQL queries.
* Each **class** in `entities.py` (like `Month`, `Expense`, `Transfer`) corresponds to a **table** in PostgreSQL.
* Each **attribute** of the class (like `income`, `category`, `amount`) corresponds to a **column** in that table.

So, `entities.py` is the **single source of truth** about your database structure for:

* SQLAlchemy (to read/write data)
* Alembic (to generate & run migrations)

---

## 3. What each model means

### `Base`

* Special parent class from SQLAlchemy.
* Every other model (`Month`, `Expense`, etc.) inherits from it.
* Keeps a record of all tables so migrations and session know what exists.

### `Month`

* One row = one calendar month of your financial life.
* Important columns:

  * `year`, `month` → like (2025, 11)
  * `income` → monthly income
  * `fixed_budget`, `emergency_budget`, `investments_budget`, `goals_budget`, `fun_budget`, `buffer_budget`
* Relationships:

  * `expenses` → list of all `Expense` rows linked to that month.
  * `transfers` → list of all `Transfer` rows linked to that month.
* Constraint:

  * `UniqueConstraint("year", "month")` → prevents duplicate months.

### `Expense`

* One row = a specific expense you recorded.
* Important columns:

  * `month_id` → foreign key linking to `Month.id` (the month this expense belongs to).
  * `dt` → date of the expense.
  * `category` → text label (“Groceries”, “Rent”, etc.).
  * `amount` → how much you spent.
  * `note` → optional description.

* Relationship:
  * `month` → the `Month` object this expense belongs to.

* Foreign key behavior:
  * `ondelete="CASCADE"` → if you delete a `Month`, all its `expenses` are also deleted.

### `Transfer`

* One row = moving money out of main account into:
  * emergency fund
  * investment account
  * goal account

* Important columns:
  * `month_id` → the month this transfer is associated with.
  * `dt` → date of the transfer.
  * `kind` → `'emergency'`, `'investment'`, or `'goal'`.
  * `amount` → how much money was moved.

* Constraint:
  * `CheckConstraint("kind in ('emergency','investment','goal')")`
    * Database will **reject** any row where `kind` is something else (`'pizza'`, `'random'`, etc.).

* Relationship:
  * `month` → the `Month` object this transfer belongs to.

### `SavingsGoal` (optional but nice)

* One row = Long-term savings goals, like:
    - 'Emergency fund' target 9000
    - 'Travel Japan 2026' target 3000
    Independent of Month; tracks target and current saved amount.

* Example:
  * name: `Emergency Fund`
  * target: `9000`
  * current: `3400`

* Constraints:
  * `name` is `unique=True` → no duplicate goal names.

* Used for:
  * Progress bars for goals across months.

### `NetWorth`

* One row = your total wealth snapshot on a given day.
* Columns:
  * `dt` → date of the snapshot.
  * `assets` → total assets (cash, investments, etc.).
  * `debts` → loans, credit card debt, etc.
* You can compute net worth in Python as `assets - debts`.

## About “Category” & “Budget” models

At the moment:

* `category` is just a text column on `Expense`:

  ```python
  category: Mapped[str] = mapped_column(String, nullable=False)
  ```
* “budget” is represented by numeric fields on `Month`:

  * `fixed_budget`, `fun_budget`, etc.

That’s perfectly fine for version 1.
Later, if you want:

* A real `Category` table (with color, icon, type),
* A `BudgetLine` table (budget per category),

we can add those as **new models** in `entities.py`, update the services, and run a new migration.

## 5. Various _Constraints_ used

Constraints are rules that the **database** enforces so your data doesn’t go crazy.

In this file we used:

### Primary Key

```python
id: Mapped[int] = mapped_column(primary_key=True)
```

* Guarantee each row has a unique identifier (`id`).
* Used to link tables (via `ForeignKey`).

### Foreign Key

```python
month_id: Mapped[int] = mapped_column(
    ForeignKey("months.id", ondelete="CASCADE"),
)
```

* Says: “this row belongs to that other table”.
* Example: every `Expense` must point to a valid `Month`.
* `ondelete="CASCADE"` → delete the month = auto-delete its expenses.

### UniqueConstraint

```python
__table_args__ = (
    UniqueConstraint("year", "month", name="uq_month_year_month"),
)
```

* Prevents two rows with the same `(year, month)` combination.

### CheckConstraint

```python
CheckConstraint(
    "kind in ('emergency','investment','goal')",
    name="ck_transfer_kind",
)
```

* Ensures the value in `kind` is one of the allowed ones.
* Database will refuse invalid rows.

These are like **strong rules** at the database level, so even if your Python code has a bug, your data stays sane.

## 6. How `entities.py` connects to Alembic

You saw this in your error:

```python
from finflow.infrastructure.orm.entities import Base
```

Alembic needs:

1. **To import your `Base`**
   So it knows all your models and tables.

2. **To read `Base.metadata`**
   This is an object that collects the definitions of **all** ORM classes (tables) you defined.

3. When you run:

   ```bash
   alembic revision --autogenerate -m "init"
   ```

   Alembic compares:

   * What tables exist in the *database*
     vs.
   * What tables are defined in `entities.py` (`Base.metadata`)

   and auto-generates a migration script.

4. `alembic upgrade head` runs that migration → actually creates the tables in PostgreSQL.

So: **if `entities.py` is missing or wrong, Alembic has no idea what your DB is supposed to look like.**

