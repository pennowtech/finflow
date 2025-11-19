# ADR 12 — Import/Export Format: CSV + JSON

### Status: 
Accepted

### Context
Users want portability across:

* Excel
* Notion
* Google Sheets

### Decision
Support:

* CSV export for spreadsheets
* JSON for full snapshots

Hint: Implementation in: `finflow/utils/helpers.py`

### Consequences
* Simple I/O operations
* Easy cross-tool migration