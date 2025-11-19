# ADR-009: Domain Modeling Approach

## Status
Accepted

## Context
Financial applications need clear modeling of money, time periods, and transactions.

## Decision
Implement domain model using:
- Entities: Month, Expense, Transfer
- Value Objects: Money, DateRange
- Aggregates: MonthlyBudget

## Consequences
- + Clear domain logic
- + Business rules enforceable in services