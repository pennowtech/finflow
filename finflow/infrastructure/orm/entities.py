# Copyright (c) 2025 Sukhdeep Singh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# finflow/infrastructure/orm/entities.py
from __future__ import annotations

from datetime import date
from decimal import Decimal
from typing import Optional

from sqlalchemy import (
    String,
    Integer,
    Numeric,
    Date,
    CheckConstraint,
    UniqueConstraint,
    ForeignKey,
)
from sqlalchemy.orm import (
    DeclarativeBase,
    Mapped,
    mapped_column,
    relationship,
)


class Base(DeclarativeBase):
    """Base class for all ORM entities."""

    pass


# ─────────────────────────────
# Core finance entities
# ─────────────────────────────


class Month(Base):
    """
    one calendar month of your financial life. (e.g. 2025-11).
    Stores high-level budget envelopes (fixed, emergency, goals, etc.)
    and links to detailed expenses, transfers, and per-category budgets.

    Example row:
    - year = 2025
    - month = 11
    - income = 4700.00
    - fixed_budget = 1500.00, etc.
    """

    __tablename__ = "months"

    id: Mapped[int] = mapped_column(primary_key=True)
    year: Mapped[int] = mapped_column(Integer, nullable=False)
    month: Mapped[int] = mapped_column(Integer, nullable=False)

    income: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0, nullable=False)
    fixed_budget: Mapped[Decimal] = mapped_column(
        Numeric(12, 2), default=0, nullable=False
    )
    emergency_budget: Mapped[Decimal] = mapped_column(
        Numeric(12, 2), default=0, nullable=False
    )
    investments_budget: Mapped[Decimal] = mapped_column(
        Numeric(12, 2), default=0, nullable=False
    )
    goals_budget: Mapped[Decimal] = mapped_column(
        Numeric(12, 2), default=0, nullable=False
    )
    fun_budget: Mapped[Decimal] = mapped_column(
        Numeric(12, 2), default=0, nullable=False
    )
    buffer_budget: Mapped[Decimal] = mapped_column(
        Numeric(12, 2), default=0, nullable=False
    )

    # Relationships: expenses → list of all Expense rows linked to that month.
    expenses: Mapped[list[Expense]] = relationship(
        back_populates="month",
        cascade="all, delete-orphan",
    )

    # Relationships: transfers → list of all Transfer rows linked to that month.
    transfers: Mapped[list[Transfer]] = relationship(
        back_populates="month",
        cascade="all, delete-orphan",
    )

    # Relationships: budgets → list of all budgets rows linked to that month.
    budgets: Mapped[list[Budget]] = relationship(
        back_populates="month",
        cascade="all, delete-orphan",
    )

    __table_args__ = (
        # Example: you cannot have two rows for the same (year, month)
        UniqueConstraint("year", "month", name="uq_month_year_month"),
    )


class Expense(Base):
    """
    A specific expense you recorded: date, category, amount, and optional note.
    Belongs to a Month and (optionally) a high-level Category.

    Example row:
    - month_id = 1
    - dt = '2025-11-12'
    - category = 'Groceries'
    - amount = 45.50
    - note = 'Lidl'
    """

    __tablename__ = "expenses"

    id: Mapped[int] = mapped_column(primary_key=True)
    month_id: Mapped[int] = mapped_column(
        ForeignKey("months.id", ondelete="CASCADE"),
        nullable=False,
    )
    dt: Mapped[date] = mapped_column(Date, nullable=False)
    category_name: Mapped[str] = mapped_column(
        "category",
        String,
        nullable=False,
    )
    amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    note: Mapped[Optional[str]] = mapped_column(String, nullable=True)

    # Optional link to Category (normalized category table)
    category_id: Mapped[Optional[int]] = mapped_column(
        ForeignKey("categories.id", ondelete="SET NULL"),
        nullable=True,
    )

    month: Mapped[Month] = relationship(back_populates="expenses")
    category: Mapped[Optional[Category]] = relationship(back_populates="expenses")


class Transfer(Base):
    """
    Represents money moved OUT of your main account into:
    - emergency fund
    - investment account
    - goal / travel pot

    'kind' tells which type of transfer this is.
        
    Used to track actual transfers against monthly budget envelopes.
    """

    __tablename__ = "transfers"

    id: Mapped[int] = mapped_column(primary_key=True)
    month_id: Mapped[int] = mapped_column(
        ForeignKey("months.id", ondelete="CASCADE"),
        nullable=False,
    )
    dt: Mapped[date] = mapped_column(Date, nullable=False)
    kind: Mapped[str] = mapped_column(String, nullable=False)
    amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    note: Mapped[Optional[str]] = mapped_column(String, nullable=True)

    month: Mapped[Month] = relationship(back_populates="transfers")

    # 'kind' is one of: 'emergency', 'investment', 'goal'
    __table_args__ = (
        CheckConstraint(
            "kind in ('emergency','investment','goal')",
            name="ck_transfer_kind",
        ),
    )


class SavingsGoal(Base):
    """
    Long-term savings goals, like:
    - 'Emergency fund' target 9000
    - 'Travel Japan 2026' target 3000

    Independent of Month; tracks target and current saved amount.
    """

    __tablename__ = "savings_goals"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String, unique=True, nullable=False)
    target: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    current: Mapped[Decimal] = mapped_column(Numeric(12, 2), default=0, nullable=False)


class NetWorth(Base):
    """
    Snapshot of your financial position on a given date.

    Example row:
    - dt = '2025-11-01'
    - assets = 25000.00
    - debts = 5000.00

    Stores total assets and debts so you can graph progress over time.
    """

    __tablename__ = "net_worth"

    id: Mapped[int] = mapped_column(primary_key=True)
    dt: Mapped[date] = mapped_column(Date, nullable=False)
    assets: Mapped[Decimal] = mapped_column(Numeric(14, 2), nullable=False)
    debts: Mapped[Decimal] = mapped_column(Numeric(14, 2), nullable=False)


# ─────────────────────────────
# Category & per-category budget
# ─────────────────────────────


class Category(Base):
    """
    Normalized expense category table.
    Lets you categorize expenses and define per-category budgets.
    """

    __tablename__ = "categories"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String, unique=True, nullable=False)
    type: Mapped[str] = mapped_column(
        String,
        nullable=False,
        default="variable",  # e.g. 'fixed', 'variable', 'savings', 'income'
    )
    is_active: Mapped[bool] = mapped_column(default=True, nullable=False)

    expenses: Mapped[list[Expense]] = relationship(back_populates="category")
    budgets: Mapped[list[Budget]] = relationship(back_populates="category")


class Budget(Base):
    """
    Optional per-category budget (e.g. 300€ for Groceries inside a Month).
    This complements the high-level budgets stored on Month.
    """

    __tablename__ = "category_budgets"

    id: Mapped[int] = mapped_column(primary_key=True)

    month_id: Mapped[int] = mapped_column(
        ForeignKey("months.id", ondelete="CASCADE"),
        nullable=False,
    )
    category_id: Mapped[int] = mapped_column(
        ForeignKey("categories.id", ondelete="CASCADE"),
        nullable=False,
    )

    amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)

    month: Mapped[Month] = relationship(back_populates="category_budgets")
    category: Mapped[Category] = relationship(back_populates="category_budgets")

    __table_args__ = (
        UniqueConstraint(
            "month_id",
            "category_id",
            name="uq_budget_month_category",
        ),
    )
