# Branching Strategy

To make VS Code automatically link branches and commits to GitHub Issues, use the **GitHub Issue Branch Naming Convention** supported by the **GitHub Pull Requests and Issues extension**.
This helps to maintain clear traceability between GitHub Issues, branches, and commits, while following modern Git best practices and VS Code automation.

- [Branching Strategy](#branching-strategy)
    - [Core Concept](#core-concept)
  - [Branch Naming Pattern](#branch-naming-pattern)
  - [Example Workflow](#example-workflow)
  - [Commit and PR conventions](#commit-and-pr-conventions)
    - [Examples](#examples)
  - [Tips](#tips)
  - [Suggested Long-Lived Branches](#suggested-long-lived-branches)
  - [Merge Rules](#merge-rules)

### Core Concept

- Each **feature**, **bug fix**, or **documentation task** gets its **own branch**.
- Branches must include the **issue number**, so GitHub and VS Code automatically link them.

---

## Branch Naming Pattern

| Type             | Prefix      | Example                           | Notes                               |
| ---------------- | ----------- | --------------------------------- | ----------------------------------- |
| ✨ Feature        | `feat/`     | `feat/23-budget-dashboard-ui`     | New features or enhancements        |
| 🐛 Bug Fix       | `fix/`      | `fix/31-db-connection-timeout`    | Code or config bug fixes            |
| 🧱 Refactor      | `refactor/` | `refactor/45-service-layer`       | Non-functional code improvements    |
| 🧪 Test          | `test/`     | `test/50-repository-layer`        | Add or update tests                 |
| 📚 Documentation | `docs/`     | `docs/12-add-documentation-files` | Docs, README, guidelines            |
| ⚙️ CI/CD         | `ci/`       | `ci/60-github-actions-update`     | Pipelines, workflows                |
| 🧩 Chore         | `chore/`    | `chore/70-update-deps`            | Maintenance tasks, dependency bumps |


## Example Workflow

1. **Create a GitHub Issue**  
   Example: `#12 — Add Documentation Files`

2. **Create a Branch from Main (either through VSCode or following CLI command)**
    ```bash
    git checkout -b docs/12-add-documentation-files
    ```
    > Always include the issue number first, then a short, case summary

3. **Work in VS Code**

   * Make sure you have the “GitHub Pull Requests and Issues” extension installed.
   * VS Code detects the `#12` in your branch name and links it to the issue automatically.

4. **Commit with Conventional Message**

    ```bash
    git commit -m "docs(#12): add professional documentation files"
    ```

5. **Push and Open Pull Request**

   ```bash
   git push origin docs/12-add-documentation-files
   ```

   As soon as you push, GitHub will automatically link this PR to **Issue #12**.

6. GitHub shows the PR as **“linked to issue #12”**

---

## Commit and PR conventions

- Commit message format: `<type>(scope): <short summary>`
  - `feat(ui): add expense import (closes #123)`
  - `fix(db): handle null notes (fixes #248)`

- When creating a PR, include **closing keywords** in the PR description:
   - `Closes #123` (or `Fixes #123`, `Resolves #123`)
   - This automatically closes the issue when the PR merges.

### Examples

- New feature:  
  Branch name: `feat/456-export-csv`  
  Commit title: `feat(#456): export csv"`
  PR title: `feat(export): add CSV export`
  PR description: `... Fixes #456`

- Bug fix:  
  
  Branch name: `fix/471-null-note-crash`  
  Commit title: `fix(#471): handle null note on import"`
  PR title: `fix(expenses): handle null note on import`
  PR description: `... Closes #471`

---

## Tips

- Keep branch names short and descriptive.
- Use issue numbers consistently to link work automatically.
  - Reference issues in commits and PRs with `#123` and closing keywords (`fixes`, `closes`) to automate workflow.
  - Example:
- Keep `main` always **stable** and **deployable**.
- Merge changes via PR (no direct commits to `main`).

---

## Suggested Long-Lived Branches

| Branch      | Purpose                                   |
| ----------- | ----------------------------------------- |
| `main`      | Stable, production-ready                  |
| `develop`   | Staging and pre-release testing           |
| `feature/*` | Temporary feature branches from `develop` |
| `hotfix/*`  | Urgent fixes branched off `main`          |

---

## Merge Rules

- Squash or rebase before merging
- Ensure PR description references the issue, e.g. “Closes #12”
- Use **Squash and Merge** to produce a clean, single commit on `main`.
  - The squash commit message should include the issue number, e.g.:
    - `feat: add recurring transfers (#123)`
- Branches are **deleted after merge** (keep the repo tidy).

