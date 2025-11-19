# ADR-010: Charting Library — Matplotlib

## Status
Accepted

## Context
FinFlow needs basic data visualization inside a PyQt6 desktop app:
- Pie charts for “expenses by category” and “budget allocation”
- Possibly line or bar charts for trends over time
- Charts must integrate with the existing PyQt6 UI

We considered several options: Matplotlib, QtCharts/PyQtCharts, Plotly (via WebView), and others.

## Decision
Use **Matplotlib** as the primary charting library, integrated via `FigureCanvasQTAgg` in the `Charts` tab.

## Consequences

### Positive
- Well-known, mature Python plotting library.
- Rich ecosystem of examples and documentation.
- Straightforward integration with PyQt6.
- Keeps the tech stack purely Python (no HTML/JS for charts).

### Negative
- Not a native Qt widget — styling may differ slightly from Qt theme.
- Highly interactive dashboards require additional work compared to Plotly.

## Alternatives Considered

1. **QtCharts / PyQtCharts**
   - Pros: Native Qt integration, good for dynamic UIs.
   - Cons: Smaller ecosystem, fewer examples, adds library coupling to Qt-specific charts.

2. **Plotly via WebView**
   - Pros: Very interactive and visually appealing.
   - Cons: Requires HTML/JS embedding, heavier stack than needed for local desktop budgeting.

3. **No Charts / Text-Only**
   - Pros: Simpler implementation.
   - Cons: Much worse UX; visualization is a core value for a finance dashboard.

## Related
- ADR-001: Architecture Style — Layered + Hexagonal Hybrid  
- ADR-007: GUI Framework — PyQt6
