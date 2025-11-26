# Copyright 2025 OGSSINGH
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

import sys
from PySide6 import QtCore, QtGui, QtWidgets

from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QPainter, QPen, QColor, QFont, QCursor, QIcon
from PySide6.QtWidgets import QFrame, QWidget, QStyle, QToolTip


# SavingsDonutChart dependencies
from PySide6.QtCharts import QChart, QChartView, QPieSeries, QPieSlice
from PySide6.QtCore import QMargins

# Matplotlib dependencies
import seaborn as sns
import mplcursors

from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure

# Icon library
import qtawesome as qta

#   -------- Qt message handler to suppress warnings ----------
def qt_message_handler(mode, context, message):
    # Filter out the noisy font warning
    if "QFont::setPointSize: Point size <= 0" in message:
        return
    # Forward everything else to stdout (or stderr)
    print(message)


QtCore.qInstallMessageHandler(qt_message_handler)

# ---------- Matplotlib canvas ----------


class MatplotlibCanvas(FigureCanvas):
    # emit raw coords under cursor (x, y) in data coordinates
    pointHovered = QtCore.Signal(float, float)

    def __init__(self, parent=None, data=None, kind="line", color="#ff7676"):
        self.data = data or []
        self.kind = kind
        self.color = color

        fig = Figure(figsize=(3, 2), dpi=100)
        self.axes = fig.add_subplot(111)
        fig.patch.set_facecolor("#15183f")
        self.axes.set_facecolor("#15183f")

        super().__init__(fig)
        self.setParent(parent)
        self.setMinimumHeight(110)

        self.plot(self.data, self.kind, self.color)

        # connect hover events (mouse move inside figure)
        self._cid_motion = self.mpl_connect("motion_notify_event", self.on_hover)
        self._cid_leave = self.mpl_connect("figure_leave_event", self.on_leave)

    def plot(self, data, kind="line", color = "#ff7676"):
        self.data = data or []
        self.kind = kind

        self.axes.clear()
        if self.data:
            x = list(range(1, len(self.data) + 1))
            if kind == "bar":
                self.axes.bar(x, self.data, color=color)
            else:
                self.axes.plot(x, self.data, marker="o", color=color)

        self.axes.set_xticks([])
        self.axes.set_yticks([])
        self.axes.margins(0.1)
        self.figure.tight_layout()
        self.draw()

    # ----- hover handling -----

    def on_hover(self, event):
        # only react inside the axes, with valid data coordinates
        if event.inaxes != self.axes or event.xdata is None or event.ydata is None:
            QToolTip.hideText()
            return

        x_val = float(event.xdata)
        y_val = float(event.ydata)

        # format however you like
        text = f"x = {x_val:.2f}\ny = {y_val:.2f}"

        # show Qt tooltip at mouse position
        QToolTip.showText(QCursor.pos(), text, self)

        # also emit signal if parent wants to react
        self.pointHovered.emit(x_val, y_val)

    def on_leave(self, event):
        QToolTip.hideText()


# ---------- Small reusable widgets ----------


class Card(QtWidgets.QFrame):
    def __init__(self, title="", value="", subtitle="", parent=None):
        super().__init__(parent)
        self.setObjectName("card")
        layout = QtWidgets.QVBoxLayout(self)
        layout.setContentsMargins(18, 16, 18, 16)
        layout.setSpacing(6)

        self.titleLabel = QtWidgets.QLabel(title)
        self.titleLabel.setObjectName("cardTitle")

        self.valueLabel = QtWidgets.QLabel(value)
        self.valueLabel.setObjectName("cardValue")

        self.subtitleLabel = QtWidgets.QLabel(subtitle)
        self.subtitleLabel.setObjectName("cardSubtitle")

        layout.addWidget(self.titleLabel)
        layout.addSpacing(4)
        layout.addWidget(self.valueLabel)
        layout.addStretch()
        layout.addWidget(self.subtitleLabel)


class CategoryPieCard(QtWidgets.QFrame):
    """Popular Category card with Qt pie chart + 3-dot button."""

    moreClicked = QtCore.Signal()

    def __init__(self, title: str, categories: list[tuple[str, float]], parent=None):
        """
        categories: list of (name, value) pairs, e.g.
            [("Housing", 1200.0), ("Food", 460.0), ...]
        """
        super().__init__(parent)
        self.setObjectName("card")
        self.categories = categories

        main_layout = QtWidgets.QVBoxLayout(self)
        main_layout.setContentsMargins(18, 16, 18, 16)
        main_layout.setSpacing(10)

        # ----- Header with title + more button -----
        header = QtWidgets.QHBoxLayout()
        titleLabel = QtWidgets.QLabel(title)
        titleLabel.setObjectName("cardTitle")
        header.addWidget(titleLabel)
        header.addStretch()

        self.moreBtn = QtWidgets.QToolButton()
        self.moreBtn.setObjectName("iconButton")
        # if using qtawesome:
        # self.moreBtn.setIcon(qta.icon("fa5s.ellipsis-h", color="#b1b6e5"))
        # self.moreBtn.setIconSize(QtCore.QSize(16, 16))
        # self.moreBtn.setToolButtonStyle(QtWidgets.QToolButton.ToolButtonIconOnly)
        self.moreBtn.setText("⋯")
        header.addWidget(self.moreBtn)

        main_layout.addLayout(header)

        # ----- Body: left list + right pie chart -----
        body = QtWidgets.QHBoxLayout()
        body.setSpacing(12)

        # ---- Left: top N categories as list ----
        list_layout = QtWidgets.QVBoxLayout()
        list_layout.setSpacing(6)

        max_preview = 4
        for idx, (name, value) in enumerate(categories):
            if idx >= max_preview:
                break
            row = QtWidgets.QHBoxLayout()
            text_layout = QtWidgets.QVBoxLayout()
            lblTitle = QtWidgets.QLabel(name)
            lblTitle.setObjectName("itemTitle")

            lblSub = QtWidgets.QLabel(f"$ {value:,.2f} · Last Week")
            lblSub.setObjectName("itemSubtitle")

            text_layout.addWidget(lblTitle)
            text_layout.addWidget(lblSub)
            row.addLayout(text_layout)
            row.addStretch()
            list_layout.addLayout(row)

        list_layout.addStretch()
        body.addLayout(list_layout, 2)  # give list a bit more space

        # ---- Right: pie chart ----
        pie_widget = QtWidgets.QWidget()
        pie_layout = QtWidgets.QVBoxLayout(pie_widget)
        pie_layout.setContentsMargins(0, 0, 0, 0)

        labels = [c[0] for c in categories]
        values = [c[1] for c in categories]

        fig = Figure(figsize=(2.0, 2.0), dpi=100)
        ax = fig.add_subplot(111)
        fig.patch.set_facecolor("#15183f")
        ax.set_facecolor("#15183f")

        colors = ["#5b7cfa", "#23d3a3", "#ff4d6d", "#fbbf24", "#a855f7", "#38bdf8"]
        colors = colors[: len(values)]

        wedges, _ = ax.pie(
            values,
            labels=None,  # no labels in chart; list on the left already shows them
            startangle=90,
            colors=colors,
            wedgeprops={"linewidth": 0.5, "edgecolor": "#0e1131"},
        )
        ax.set_aspect("equal")
        fig.tight_layout()

        pie_canvas = FigureCanvas(fig)
        pie_canvas.setMinimumSize(140, 140)
        pie_layout.addWidget(pie_canvas)

        body.addWidget(pie_widget, 1)

        main_layout.addLayout(body)

        self.moreBtn.clicked.connect(self.moreClicked.emit)


class GraphCard(QtWidgets.QFrame):
    def __init__(
        self, title="", value="", subtitle="", data=None, kind="line", color = "#ff7676", parent=None
    ):
        super().__init__(parent)
        self.setObjectName("card")
        layout = QtWidgets.QVBoxLayout(self)
        layout.setContentsMargins(18, 16, 18, 16)
        layout.setSpacing(8)

        header = QtWidgets.QHBoxLayout()
        self.titleLabel = QtWidgets.QLabel(title)
        self.titleLabel.setObjectName("cardTitle")
        header.addWidget(self.titleLabel)
        header.addStretch()

        self.valueLabel = QtWidgets.QLabel(value)
        self.valueLabel.setObjectName("cardValueSmall")
        header.addWidget(self.valueLabel)
        layout.addLayout(header)

        self.subtitleLabel = QtWidgets.QLabel(subtitle)
        self.subtitleLabel.setObjectName("cardSubtitle")
        layout.addWidget(self.subtitleLabel)

        self.canvas = MatplotlibCanvas(
            self, data=data or [0], kind=kind, color=color
        )
        layout.addWidget(self.canvas)


class CircleProgressWidget(QWidget):
    def __init__(self, current: float, target: float, parent=None):
        super().__init__(parent)
        self.current = current
        self.target = target
        self.setMinimumSize(90, 90)

    def setValues(self, current: float, target: float):
        self.current = current
        self.target = target
        self.update()

    def paintEvent(self, event):
        super().paintEvent(event)
        painter = QPainter(self)
        painter.setRenderHint(QPainter.Antialiasing)

        # make a square rect centered in the widget -> true circle, not ellipse
        size = min(self.width(), self.height()) - 2
        rect = QtCore.QRectF(2, 2, size, size)
        rect.moveCenter(self.rect().center())

        # background circle
        base_pen = QPen(QColor("#273066"), 4)
        painter.setPen(base_pen)
        painter.setBrush(Qt.NoBrush)
        painter.drawEllipse(rect)

        # progress arc
        if self.target > 0:
            ratio = max(0.0, min(1.0, self.current / self.target))
            span_angle = int(360 * ratio * 16)  # degrees * 16
            progress_pen = QPen(QColor("#12aa81"), 4)
            painter.setPen(progress_pen)
            # start at top (90°) and go clockwise (negative)
            painter.drawArc(rect, 90 * 16, -span_angle)

        # inner circle
        inner_rect = rect.adjusted(28, 28, -28, -28)
        inner_pen = QPen(QColor("#23d3a3"), 2)
        painter.setPen(inner_pen)
        painter.drawEllipse(inner_rect)

        # simple shield/$ icon (stylised)
        painter.setPen(QColor("#23d3a3"))
        font = QFont()
        font.setPointSize(10)
        font.setBold(True)
        painter.setFont(font)
        painter.drawText(inner_rect, Qt.AlignCenter, "$")


class SavingsDonutChart(QChartView):
    def __init__(self, current: float, target: float, parent=None):
        super().__init__(parent)
        self.current = current
        self.target = target

        self.series = QPieSeries()
        self._build_series()

        chart = QChart()
        chart.addSeries(self.series)
        chart.legend().setVisible(False)
        chart.setBackgroundVisible(False)
        chart.setBackgroundRoundness(0)
        chart.setMargins(QMargins(0, 0, 0, 0))
        chart.setContentsMargins(0, 0, 0, 0)
        chart.setAnimationOptions(QChart.AllAnimations)

        self.setChart(chart)
        self.setRenderHint(QPainter.Antialiasing)
        self.setStyleSheet("background: transparent;")
        self.setFixedSize(120, 120)

        self.series.setLabelsPosition(QPieSlice.LabelPosition.LabelOutside)

        # connect interactions
        for sl in self.series.slices():
            sl.hovered.connect(self.on_slice_hovered)
            sl.clicked.connect(self.on_slice_clicked)

    def _build_series(self):
        self.series.clear()
        if self.target <= 0:
            self.series.append("All", 1)
        else:
            achieved = max(0.0, min(self.current, self.target))
            remaining = max(0.0, self.target - achieved)
            s_ach = self.series.append("Achieved", achieved)
            s_rem = self.series.append("Remaining", remaining)

            # colours
            s_ach.setBrush(QColor("#23d3a3"))  # green
            s_rem.setBrush(QColor("#273066"))  # dark bg

        self.series.setHoleSize(0.70)
        self.series.setPieSize(0.90)

        for sl in self.series.slices():
            sl.setLabelVisible(False)
            sl.setBorderWidth(0)

    def setValues(self, current: float, target: float):
        self.current = current
        self.target = target
        self._build_series()

    # ---- interactions ----
    def on_slice_hovered(self, state: bool):
        sl = self.sender()
        if not isinstance(sl, QPieSlice):
            return
        # simple hover effect: slightly explode the hovered slice
        sl.setExploded(state)
        sl.setLabelVisible(state)

    def on_slice_clicked(self):
        sl = self.sender()
        if not isinstance(sl, QPieSlice):
            return
        # toggle selection (makes slice a bit bigger)
        sl.setExploded(not sl.isExploded())


class DetailWindow(QtWidgets.QDialog):
    """Scrollable window that shows all items for a period."""

    def __init__(self, title, items, period="Last Week", parent=None):
        super().__init__(parent)

        # frameless + themed
        self.setWindowFlags(Qt.FramelessWindowHint | Qt.Dialog)
        self.setObjectName("detailDialog")
        if parent is not None:
            self.setStyleSheet(parent.styleSheet())

        self.setWindowTitle(title)
        self.resize(420, 500)

        main = QtWidgets.QVBoxLayout(self)
        header = QtWidgets.QHBoxLayout()
        lblTitle = QtWidgets.QLabel(title)
        lblTitle.setStyleSheet("font-size: 16px; font-weight: 600;")
        header.addWidget(lblTitle)
        header.addStretch()
        lblPeriod = QtWidgets.QLabel(period)
        lblPeriod.setStyleSheet("color: gray;")
        header.addWidget(lblPeriod)
        main.addLayout(header)

        # Scroll area
        scroll = QtWidgets.QScrollArea()
        scroll.setWidgetResizable(True)
        container = QtWidgets.QWidget()
        vbox = QtWidgets.QVBoxLayout(container)
        vbox.setSpacing(10)

        for primary, secondary in items:
            row = QtWidgets.QHBoxLayout()
            textLayout = QtWidgets.QVBoxLayout()
            lbl1 = QtWidgets.QLabel(primary)
            lbl1.setStyleSheet("font-size: 13px; font-weight: 500;")
            lbl2 = QtWidgets.QLabel(secondary)
            lbl2.setStyleSheet("font-size: 11px; color: #666;")
            textLayout.addWidget(lbl1)
            textLayout.addWidget(lbl2)
            row.addLayout(textLayout)
            row.addStretch()
            vbox.addLayout(row)

        vbox.addStretch()
        scroll.setWidget(container)
        main.addWidget(scroll)

        btnClose = QtWidgets.QPushButton("Close")
        btnClose.clicked.connect(self.accept)
        main.addWidget(btnClose, alignment=Qt.AlignRight)

    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            self._drag_pos = event.globalPosition().toPoint()
        super().mousePressEvent(event)

    def mouseMoveEvent(self, event):
        if event.buttons() & Qt.LeftButton:
            try:
                diff = event.globalPosition().toPoint() - self._drag_pos
                self.move(self.pos() + diff)
                self._drag_pos = event.globalPosition().toPoint()
            except AttributeError:
                pass
        super().mouseMoveEvent(event)


class ListCard(QtWidgets.QFrame):
    """Card that shows a list and has a 'more' button."""

    moreClicked = Signal()

    def __init__(self, title="", items=None, parent=None):
        super().__init__(parent)
        if items is None:
            items = []
        self.items = items
        self.setObjectName("card")
        layout = QtWidgets.QVBoxLayout(self)
        layout.setContentsMargins(18, 16, 18, 16)
        layout.setSpacing(10)

        header = QtWidgets.QHBoxLayout()
        titleLabel = QtWidgets.QLabel(title)
        titleLabel.setObjectName("cardTitle")
        header.addWidget(titleLabel)
        header.addStretch()
        self.moreBtn = QtWidgets.QToolButton()
        self.moreBtn.setText("⋯")
        self.moreBtn.setObjectName("iconButton")
        header.addWidget(self.moreBtn)
        layout.addLayout(header)

        # Show only first few in the card; full list in detail window
        max_preview = 4
        for idx, (text, sub) in enumerate(items):
            if idx >= max_preview:
                break
            row = QtWidgets.QHBoxLayout()
            main = QtWidgets.QVBoxLayout()
            lblTitle = QtWidgets.QLabel(text)
            lblTitle.setObjectName("itemTitle")
            lblSub = QtWidgets.QLabel(sub)
            lblSub.setObjectName("itemSubtitle")
            main.addWidget(lblTitle)
            main.addWidget(lblSub)
            row.addLayout(main)
            row.addStretch()
            layout.addLayout(row)

        layout.addStretch()
        self.moreBtn.clicked.connect(self.moreClicked.emit)


class SavingsCard(QFrame):
    def __init__(self, current: float, target: float, parent=None):
        super().__init__(parent)
        self.setObjectName("card")
        self.current = current
        self.target = target
        ratio = 0 if target == 0 else current / target
        achieved_pct = int(ratio * 100)
        remaining_pct = max(0, 100 - achieved_pct)

        main_layout = QtWidgets.QHBoxLayout(self)
        main_layout.setContentsMargins(18, 16, 18, 16)
        main_layout.setSpacing(10)

        # left side text
        left = QtWidgets.QVBoxLayout()
        left.setSpacing(4)

        title = QtWidgets.QLabel("Saving")
        title.setObjectName("cardTitle")

        subtitle_top = QtWidgets.QLabel("Last Week")
        subtitle_top.setObjectName("cardSubtitle")

        value_label = QtWidgets.QLabel(f"$ {current:,.2f}")
        value_label.setObjectName("cardValue")

        # bottom metrics
        bottom = QtWidgets.QHBoxLayout()
        bottom.setSpacing(16)

        lbl_achieved = QtWidgets.QLabel(f"↑ {achieved_pct}% Achieved")
        lbl_achieved.setObjectName("savingMetricGreen")

        lbl_remaining = QtWidgets.QLabel(f"↓ {remaining_pct}% Left")
        lbl_remaining.setObjectName("savingMetricRed")

        bottom.addWidget(lbl_achieved)
        bottom.addWidget(lbl_remaining)

        left.addWidget(title)
        left.addWidget(subtitle_top)
        left.addSpacing(4)
        left.addWidget(value_label)
        left.addStretch()
        left.addLayout(bottom)

        # right side circular graph
        # circle = CircleProgressWidget(current=current, target=target)
        circle = SavingsDonutChart(current=current, target=target)
        circle.setObjectName("savingCircle")

        main_layout.addLayout(left)
        main_layout.addStretch()
        main_layout.addWidget(circle)

class UpcomingPaymentsCard(QtWidgets.QFrame):
    showMoreClicked = QtCore.Signal()

    def __init__(self, title: str, items: list[tuple[str, str, str]], parent=None):
        """
        items: (name, subtitle, amount_str)
        """
        super().__init__(parent)
        self.items = items
        self.setObjectName("card")

        layout = QtWidgets.QVBoxLayout(self)
        layout.setContentsMargins(18, 16, 18, 16)
        layout.setSpacing(10)

        # header
        header = QtWidgets.QHBoxLayout()
        titleLabel = QtWidgets.QLabel(title)
        titleLabel.setObjectName("cardTitle")
        header.addWidget(titleLabel)
        header.addStretch()

        btnShow = QtWidgets.QPushButton("Show more")
        btnShow.setObjectName("showMoreLink")
        btnShow.setFlat(True)
        btnShow.clicked.connect(self.showMoreClicked.emit)
        header.addWidget(btnShow)
        layout.addLayout(header)

        # preview rows (first 4)
        max_preview = 4
        for idx, (name, subtitle, amount) in enumerate(items[:max_preview]):
            row = QtWidgets.QHBoxLayout()
            row.setSpacing(8)

            iconLbl = QtWidgets.QLabel()
            iconLbl.setObjectName("upcomingIcon")
            iconLbl.setFixedSize(28, 28)
            row.addWidget(iconLbl)

            textBox = QtWidgets.QVBoxLayout()
            lblName = QtWidgets.QLabel(name)
            lblName.setObjectName("itemTitle")
            lblSub = QtWidgets.QLabel(subtitle)
            lblSub.setObjectName("itemSubtitle")
            textBox.addWidget(lblName)
            textBox.addWidget(lblSub)
            row.addLayout(textBox)

            row.addStretch()

            lblAmount = QtWidgets.QLabel(amount)
            lblAmount.setObjectName("upcomingAmount")
            row.addWidget(lblAmount)

            layout.addLayout(row)

        layout.addStretch()


class SavingGoalsCard(QtWidgets.QFrame):
    showMoreClicked = QtCore.Signal()

    def __init__(self, title: str, items: list[tuple[str, float, float]], parent=None):
        """
        items: (name, current, target)
        """
        super().__init__(parent)
        self.items = items
        self.setObjectName("card")

        layout = QtWidgets.QVBoxLayout(self)
        layout.setContentsMargins(18, 16, 18, 16)
        layout.setSpacing(10)

        header = QtWidgets.QHBoxLayout()
        titleLabel = QtWidgets.QLabel(title)
        titleLabel.setObjectName("cardTitle")
        header.addWidget(titleLabel)
        header.addStretch()

        btnShow = QtWidgets.QPushButton("Show more")
        btnShow.setObjectName("showMoreLink")
        btnShow.setFlat(True)
        btnShow.clicked.connect(self.showMoreClicked.emit)
        header.addWidget(btnShow)
        layout.addLayout(header)

        # preview rows (first 2)
        max_preview = 2
        for name, current, target in items[:max_preview]:
            row = QtWidgets.QHBoxLayout()
            row.setSpacing(8)

            iconLbl = QtWidgets.QLabel()
            iconLbl.setObjectName("goalIcon")
            iconLbl.setFixedSize(28, 28)
            row.addWidget(iconLbl)

            textLayout = QtWidgets.QVBoxLayout()
            lblName = QtWidgets.QLabel(name)
            lblName.setObjectName("itemTitle")
            lblSub = QtWidgets.QLabel(f"${current:,.2f} of ${target:,.2f}")
            lblSub.setObjectName("itemSubtitle")
            textLayout.addWidget(lblName)
            textLayout.addWidget(lblSub)

            prog = QtWidgets.QProgressBar()
            prog.setObjectName("goalProgress")
            prog.setMinimum(0)
            prog.setMaximum(100)
            pct = 0 if target == 0 else int(min(100, (current / target) * 100))
            prog.setValue(pct)
            textLayout.addWidget(prog)

            row.addLayout(textLayout)
            layout.addLayout(row)

        layout.addStretch()


# ---------- Main window ----------


class MainWindow(QtWidgets.QMainWindow):

    def __init__(self):
        super().__init__()
        self.setWindowTitle("FinFlow Dashboard")
        self.setWindowFlags(Qt.FramelessWindowHint | Qt.Window)
        self.resize(1280, 768)

        # ---- single central widget ----
        central = QtWidgets.QWidget()
        self.setCentralWidget(central)

        # main vertical layout: [window buttons bar] + [content area]
        mainLayout = QtWidgets.QVBoxLayout(central)
        mainLayout.setContentsMargins(0, 0, 0, 0)
        mainLayout.setSpacing(0)

        # ===== TOP BAR: window controls (shown for all tabs) =====
        topBar = QtWidgets.QHBoxLayout()
        topBar.setContentsMargins(8, 8, 8, 0)
        topBar.addStretch()  # empty left side
        topBar.addLayout(self.create_window_buttons())  # min / max / close
        mainLayout.addLayout(topBar)

        # ===== CONTENT AREA: sidebar + stacked pages =====
        rootLayout = QtWidgets.QHBoxLayout()
        rootLayout.setContentsMargins(24, 24, 24, 24)
        rootLayout.setSpacing(18)

        # ---- Sidebar (tabs) ----
        sidebar = QtWidgets.QFrame()
        sidebar.setObjectName("sidebar")
        sidebar.setFixedWidth(90)
        sideLayout = QtWidgets.QVBoxLayout(sidebar)
        sideLayout.setSpacing(30)

        logo = QtWidgets.QLabel("💸")
        logo.setAlignment(Qt.AlignCenter)
        logo.setObjectName("logo")
        sideLayout.addWidget(logo)

        navLayout = QtWidgets.QVBoxLayout()
        navLayout.setContentsMargins(0, 0, 0, 0)
        navLayout.setSpacing(12)

        self.stack = QtWidgets.QStackedWidget()

        # ---- Pages (now only content, no window buttons here) ----
        overviewPage = self.create_dashboard_page()
        transactionsPage = self.create_transactions_page()
        accountsPage = self.create_placeholder_page("Accounts")
        budgetPage = self.create_placeholder_page("Budget")
        goalsPage = self.create_placeholder_page("Goals")
        settingsPage = self.create_placeholder_page("Settings")
        helpPage = self.create_help_page("Help")

        for page in [
            overviewPage,
            transactionsPage,
            accountsPage,
            budgetPage,
            goalsPage,
            settingsPage,
            helpPage
        ]:
            self.stack.addWidget(page)

        self.navButtons = []

        def add_nav(text, page_index, fa_icon_name):
            btn = QtWidgets.QToolButton()
            btn.setToolButtonStyle(Qt.ToolButtonTextUnderIcon)
            btn.setCheckable(True)
            btn.setObjectName("navButton")

            # make sure font has a real size
            font = btn.font()
            if font.pointSize() <= 0:
                font.setPointSize(10)
            btn.setFont(font)

            btn.setSizePolicy(
                QtWidgets.QSizePolicy.Expanding,
                QtWidgets.QSizePolicy.Preferred,
            )

            btn.setIcon(qta.icon(f"fa6s.{fa_icon_name}", color="#8f97c5"))
            btn.setIconSize(QtCore.QSize(26, 26))
            btn.setToolTip(text)
            btn.setText(text)

            btn.clicked.connect(
                lambda checked, idx=page_index, b=btn: self.on_nav_clicked(idx, b)
            )
            navLayout.addWidget(btn)
            self.navButtons.append(btn)
            return btn

        add_nav("Overview",      0, "person-chalkboard")
        add_nav("Transactions",  1, "money-bill-transfer")
        add_nav("Accounts",      2, "wallet")
        add_nav("Budget",        3, "chart-pie")
        add_nav("Goals",         4, "bullseye")
        sideLayout.addLayout(navLayout)
        sideLayout.addStretch()
        add_nav("Settings", 5, "gear")
        add_nav("Help", 6, "circle-info")

        rootLayout.addWidget(sidebar)
        rootLayout.addWidget(self.stack)

        # add content area to main layout under topBar
        mainLayout.addLayout(rootLayout)

        # Activate first tab
        self.navButtons[0].setChecked(True)

        self.apply_styles()

    # ----- Navigation -----

    def on_nav_clicked(self, index, button):
        self.stack.setCurrentIndex(index)
        for b in self.navButtons:
            b.setChecked(b is button)

    # ----- Pages -----

    def create_placeholder_page(self, title):
        page = QtWidgets.QFrame()
        page.setObjectName("mainArea")
        layout = QtWidgets.QVBoxLayout(page)
        layout.setContentsMargins(18, 18, 18, 18)
        label = QtWidgets.QLabel(title)
        label.setObjectName("pageTitle")
        layout.addWidget(label)
        placeholder = QtWidgets.QLabel(
            f"{title} page content goes here (tables, forms, etc.)"
        )
        placeholder.setStyleSheet("color: #8f97c5;")
        layout.addWidget(placeholder)
        layout.addStretch()
        return page

    def toggle_max_restore(self):
        if self.isMaximized():
            self.showNormal()
        else:
            self.showMaximized()

    def create_window_buttons(self) -> QtWidgets.QHBoxLayout:
        """Create min/max/close buttons for the current page."""
        winButtons = QtWidgets.QHBoxLayout()
        winButtons.setSpacing(4)

        btnMin = QtWidgets.QPushButton()
        btnMin.setIcon(
            qta.icon(
                "fa6s.window-minimize",
                color="yellow",
            )
        )
        btnMin.setFixedSize(22, 22)
        btnMin.setObjectName("winButton")

        btnMax = QtWidgets.QPushButton()
        btnMax.setIcon(
            qta.icon(
                "fa6s.clone",
                color="green",
            )
        )
        btnMax.setFixedSize(22, 22)
        btnMax.setObjectName("winButton")

        icon = qta.icon(
            "fa6s.xmark",
            color="orange",
        )

        btnClose = QtWidgets.QPushButton()
        btnClose.setIcon(icon)
        btnClose.setFixedSize(22, 22)
        btnClose.setObjectName("winButtonClose")

        btnMin.clicked.connect(self.showMinimized)
        btnMax.clicked.connect(self.toggle_max_restore)
        btnClose.clicked.connect(self.close)

        winButtons.addWidget(btnMin)
        winButtons.addWidget(btnMax)
        winButtons.addWidget(btnClose)

        return winButtons

    def create_dashboard_page(self):
        main = QtWidgets.QFrame()
        main.setObjectName("mainArea")
        mainLayout = QtWidgets.QVBoxLayout(main)
        mainLayout.setContentsMargins(18, 18, 18, 18)
        mainLayout.setSpacing(16)

        # Top bar
        topBar = QtWidgets.QHBoxLayout()
        search = QtWidgets.QLineEdit()
        search.setPlaceholderText("Hi John, click here to search…")
        search.setObjectName("searchBox")
        topBar.addWidget(search)

        topRight = QtWidgets.QHBoxLayout()
        topRight.setSpacing(12)

        weekBtn = QtWidgets.QPushButton("Last Week")
        weekBtn.setObjectName("pillButtonActive")
        monthBtn = QtWidgets.QPushButton("Last Month")
        monthBtn.setObjectName("pillButton")
        topRight.addWidget(weekBtn)
        topRight.addWidget(monthBtn)

        bellBtn = QtWidgets.QToolButton()
        bellBtn.setIcon(qta.icon("fa6s.bullhorn", color="#e3e706"))
        bellBtn.setObjectName("iconButton")
        bellBtn.setToolTip("Notifications")
        bellBtn.setIconSize(QtCore.QSize(18, 18))
        bellBtn.setToolButtonStyle(Qt.ToolButtonIconOnly)
        topRight.addWidget(bellBtn)

        avatar = QtWidgets.QLabel()
        avatar.setObjectName("avatar")
        avatar.setFixedSize(32, 32)
        nameLabel = QtWidgets.QLabel("John Doe")
        nameLabel.setObjectName("profileName")
        profileLayout = QtWidgets.QHBoxLayout()
        profileLayout.setSpacing(8)
        profileLayout.addWidget(avatar)
        profileLayout.addWidget(nameLabel)
        topRight.addLayout(profileLayout)

        topBar.addLayout(topRight)
        mainLayout.addLayout(topBar)

        # Title
        titleLabel = QtWidgets.QLabel("OVERVIEW")
        titleLabel.setObjectName("pageTitle")
        mainLayout.addWidget(titleLabel)

        # Grid
        grid = QtWidgets.QGridLayout()
        grid.setHorizontalSpacing(16)
        grid.setVerticalSpacing(16)

        # Data for graphs
        revenue_data = [800, 1200, 900, 1550, 1300, 1500, 1550]
        expenses_data = [300, 250, 400, 380, 320, 450, 420]
        freq_data = [5, 7, 6, 8, 7, 6, 9]

        # Row 0: balance card + revenue & savings graph cards
        cardBalance = Card("Current Balance", "$ 8,200.90", "VISA · · · · 2576")
        cardRevenue = GraphCard(
            "Revenue (Last Week)",
            "$ 1,550.00",
            "Trend",
            data=revenue_data,
            kind="line",
            color="#23d3a3",
        )
        cardSaving = SavingsCard(current=160.00, target=500.00)  # adjust target as you like

        # Row 1 + 2: Popular categories, expenses, frequency, history
        # numeric data for the chart
        self.category_items = [
            ("Housing", 1200.00),
            ("Food", 460.00),
            ("Entertainment", 320.50),
            ("Transportation", 249.50),
            ("Other", 140.00),
        ]

        self.history_items = [
            ("Nike", "January 23, 2019 · $119.99"),
            ("Apple Music", "January 19, 2019 · $24.99"),
            ("Playstation Plus", "January 19, 2019 · $14.99"),
            ("Starbucks Coffee", "January 14, 2019 · $14.99"),
            ("Starbucks Coffee", "January 10, 2019 · $9.99"),
            ("Netflix", "January 05, 2019 · $12.99"),
            ("Uber", "January 02, 2019 · $19.50"),
        ]

        self.upcoming_items = [
            ("10X Designers", "Monthly, next on 22 May", "$17.00"),
            ("Apple",        "Monthly, next on 8 June", "$41.00"),
            ("Spotify",      "Monthly, next on 9 June", "$11.99"),
            ("PetPlate",     "Monthly, next on 1 June", "$139.00"),
            ("Adobe",        "Monthly, next on 15 June", "$19.99"),
        ]

        self.goal_items = [
            ("Holidays", 942.08, 2000.00),
            ("New Car", 32400.34, 50000.00),
            ("Emergency Fund", 5500.00, 10000.00),
        ]

        categories = CategoryPieCard(
            "Popular Category",
            self.category_items,
        )
        categories.moreClicked.connect(self.show_categories_detail)

        expenses = GraphCard(
            "Expenses",
            "Last Week $ 1,200.00",
            "Mon – Sun",
            data=expenses_data,
            kind="line",
            color="#ff4d6d",
        )

        freqCard = GraphCard(
            "Frequency of Transactions",
            "Daily 6.6 · Weekly 36.0",
            "",
            data=freq_data,
            kind="bar",
            color="#5bc8fa",
        )

        history = ListCard(
            "History Transaction",
            self.history_items,
        )
        history.moreClicked.connect(self.show_history_detail)

        # row 3 – Upcoming payments + Saving goals
        upcomingCard = UpcomingPaymentsCard("Upcoming Payments", self.upcoming_items)
        upcomingCard.showMoreClicked.connect(self.show_upcoming_detail)

        goalsCard = SavingGoalsCard("Saving goals", self.goal_items)
        goalsCard.showMoreClicked.connect(self.show_goals_detail)

        grid.addWidget(cardBalance, 0, 0, 1, 1)
        grid.addWidget(cardRevenue, 0, 1, 1, 1)
        grid.addWidget(expenses, 0, 2, 1, 1)
        grid.addWidget(cardSaving, 0, 3, 1, 1)
        grid.addWidget(goalsCard, 1, 0, 1, 2)
        grid.addWidget(categories, 1, 2, 1, 2)
        grid.addWidget(upcomingCard, 2, 0, 1, 2)
        grid.addWidget(history, 2, 2, 1, 2)

        mainLayout.addLayout(grid)
        return main

    def create_transactions_page(self):
        page = QtWidgets.QFrame()
        page.setObjectName("mainArea")
        pageLayout = QtWidgets.QVBoxLayout(page)
        pageLayout.setContentsMargins(18, 18, 18, 18)
        pageLayout.setSpacing(16)

        # Page title
        title = QtWidgets.QLabel("TRANSACTIONS")
        title.setObjectName("pageTitle")
        pageLayout.addWidget(title)

        # ------- Add Expense card -------
        formCard = QtWidgets.QFrame()
        formCard.setObjectName("card")

        formLayout = QtWidgets.QGridLayout(formCard)
        formLayout.setContentsMargins(18, 16, 18, 16)
        formLayout.setHorizontalSpacing(18)
        formLayout.setVerticalSpacing(10)

        sectionLabel = QtWidgets.QLabel("Add Expense")
        sectionLabel.setObjectName("sectionTitle")
        formLayout.addWidget(sectionLabel, 0, 0, 1, 4)

        # Row 1 – Date, Category
        lblDate = QtWidgets.QLabel("Date")
        lblCategory = QtWidgets.QLabel("Category")
        lblDate.setObjectName("fieldLabel")
        lblCategory.setObjectName("fieldLabel")

        dateEdit = QtWidgets.QDateEdit(QtCore.QDate.currentDate())
        dateEdit.setCalendarPopup(True)
        dateEdit.setObjectName("fieldEdit")

        categoryCombo = QtWidgets.QComboBox()
        categoryCombo.setObjectName("fieldEdit")
        # You can later fill this from your ORM Category table
        categoryCombo.addItems(
            ["Housing", "Food", "Entertainment", "Transportation", "Other"]
        )

        formLayout.addWidget(lblDate, 1, 0)
        formLayout.addWidget(dateEdit, 2, 0)
        formLayout.addWidget(lblCategory, 1, 1)
        formLayout.addWidget(categoryCombo, 2, 1)

        # Row 2 – Amount, Account
        lblAmount = QtWidgets.QLabel("Amount")
        lblAmount.setObjectName("fieldLabel")

        amountSpin = QtWidgets.QDoubleSpinBox()
        amountSpin.setObjectName("fieldEdit")
        amountSpin.setMaximum(1_000_000_000)
        amountSpin.setPrefix("$ ")
        amountSpin.setDecimals(2)
        amountSpin.setSingleStep(1.0)

        lblAccount = QtWidgets.QLabel("Account")
        lblAccount.setObjectName("fieldLabel")

        accountCombo = QtWidgets.QComboBox()
        accountCombo.setObjectName("fieldEdit")
        # Later, populate from your Account entity
        accountCombo.addItems(["Main Card", "Savings", "Cash"])

        formLayout.addWidget(lblAmount, 1, 2)
        formLayout.addWidget(amountSpin, 2, 2)
        formLayout.addWidget(lblAccount, 1, 3)
        formLayout.addWidget(accountCombo, 2, 3)

        # Row 3 – Notes
        lblNotes = QtWidgets.QLabel("Notes")
        lblNotes.setObjectName("fieldLabel")

        notesEdit = QtWidgets.QPlainTextEdit()
        notesEdit.setObjectName("notesEdit")
        notesEdit.setPlaceholderText("Optional description, merchant, tags…")

        formLayout.addWidget(lblNotes, 3, 0, 1, 4)
        formLayout.addWidget(notesEdit, 4, 0, 1, 4)

        # Row 4 – Buttons + status
        buttonLayout = QtWidgets.QHBoxLayout()
        buttonLayout.setSpacing(8)

        btnAdd = QtWidgets.QPushButton("Add Expense")
        btnAdd.setObjectName("primaryButton")
        btnAdd.clicked.connect(lambda: add_expense())   

        btnClear = QtWidgets.QPushButton("Clear")
        btnClear.setObjectName("secondaryButton")
        btnClear.clicked.connect(lambda: clear_form())

        statusLabel = QtWidgets.QLabel("")
        statusLabel.setObjectName("statusLabel")

        buttonLayout.addWidget(btnAdd)
        buttonLayout.addWidget(btnClear)
        buttonLayout.addStretch()
        buttonLayout.addWidget(statusLabel)

        formLayout.addLayout(buttonLayout, 5, 0, 1, 4)

        pageLayout.addWidget(formCard)

        # ------- Recent expenses table -------
        tableCard = QtWidgets.QFrame()
        tableCard.setObjectName("card")

        tableLayout = QtWidgets.QVBoxLayout(tableCard)
        tableLayout.setContentsMargins(18, 16, 18, 16)
        tableLayout.setSpacing(10)

        headerLayout = QtWidgets.QHBoxLayout()
        tableTitle = QtWidgets.QLabel("Recent Expenses")
        tableTitle.setObjectName("sectionTitle")
        headerLayout.addWidget(tableTitle)

        headerLayout.addStretch()

        # button to delete all checked rows
        btnDeleteSelected = QtWidgets.QPushButton("Delete Selected")
        btnDeleteSelected.setObjectName("secondaryButton")
        btnDeleteSelected.clicked.connect(lambda: delete_selected_rows())
        headerLayout.addWidget(btnDeleteSelected)

        tableLayout.addLayout(headerLayout)

        # columns: [0] chk, [1] date, [2] cat, [3] account, [4] amount, [5] notes, [6] edit, [7] delete
        table = QtWidgets.QTableWidget(0, 8)
        table.setObjectName("expensesTable")
        table.setHorizontalHeaderLabels(
            ["", "Date", "Category", "Account", "Amount", "Notes", "", ""]
        )
        table.horizontalHeader().setStretchLastSection(False)
        table.horizontalHeader().setSectionResizeMode(5, QtWidgets.QHeaderView.Stretch)
        for col in [0, 6, 7]:
            table.horizontalHeader().setSectionResizeMode(
                col, QtWidgets.QHeaderView.ResizeToContents
            )
        for col in [1, 2, 3, 4]:
            table.horizontalHeader().setSectionResizeMode(
                col, QtWidgets.QHeaderView.ResizeToContents
            )

        table.verticalHeader().setVisible(False)
        table.setSelectionBehavior(QtWidgets.QTableView.SelectRows)
        table.setEditTriggers(QtWidgets.QAbstractItemView.NoEditTriggers)

        tableLayout.addWidget(table)

        pageLayout.addWidget(tableCard)

        # ------- Behaviour: add expense to table only (UI-level) -------

        def clear_form():
            dateEdit.setDate(QtCore.QDate.currentDate())
            categoryCombo.setCurrentIndex(0)
            accountCombo.setCurrentIndex(0)
            amountSpin.setValue(0.0)
            notesEdit.clear()
            statusLabel.setText("")

        def make_row_buttons(row: int):
            """Create edit/delete buttons for a specific row."""
            # Edit button
            editBtn = QtWidgets.QToolButton()
            editBtn.setObjectName("rowActionButton")
            editBtn.setIcon(
                self.style().standardIcon(QtWidgets.QStyle.SP_FileDialogDetailedView)
            )
            table.setCellWidget(row, 6, editBtn)

            # Delete button
            delBtn = QtWidgets.QToolButton()
            delBtn.setObjectName("rowActionButtonDelete")
            delBtn.setIcon(self.style().standardIcon(QtWidgets.QStyle.SP_TrashIcon))
            table.setCellWidget(row, 7, delBtn)

            # connect handlers
            editBtn.clicked.connect(lambda: on_edit_row(editBtn))
            delBtn.clicked.connect(lambda: on_delete_row(delBtn))

        def on_edit_row(button):
            # find which row this button belongs to
            for r in range(table.rowCount()):
                if table.cellWidget(r, 6) is button:
                    row = r
                    break
                if table.cellWidget(r, 7) is button:
                    row = r
                    break
            else:
                return

            # load row data into form
            date_str = table.item(row, 1).text()
            qdate = QtCore.QDate.fromString(date_str, "yyyy-MM-dd")
            if qdate.isValid():
                dateEdit.setDate(qdate)
            categoryCombo.setCurrentText(table.item(row, 2).text())
            accountCombo.setCurrentText(table.item(row, 3).text())

            amount_text = (
                table.item(row, 4).text().replace("$", "").replace(",", "").strip()
            )
            try:
                amountSpin.setValue(float(amount_text))
            except ValueError:
                pass

            notesEdit.setPlainText(table.item(row, 5).text())

            # UI choice: remove row now, user will re-save
            table.removeRow(row)
            statusLabel.setText("Editing expense…")

            # TODO: here you may also load ORM object into memory for update

        def on_delete_row(button):
            # find which row this button belongs to
            for r in range(table.rowCount()):
                if table.cellWidget(r, 7) is button:
                    row = r
                    break
            else:
                return

            # TODO: delete from DB using your ORM before removing row
            table.removeRow(row)

        def delete_selected_rows():
            # walk backwards so indices stay valid
            for r in range(table.rowCount() - 1, -1, -1):
                item = table.item(r, 0)
                if item and item.checkState() == QtCore.Qt.Checked:
                    # TODO: delete from DB as well
                    table.removeRow(r)

        def add_expense():
            amount = amountSpin.value()
            if amount <= 0:
                statusLabel.setText("Amount must be > 0")
                return

            row = table.rowCount()
            table.insertRow(row)

            # column 0: checkbox item
            chk_item = QtWidgets.QTableWidgetItem("")
            chk_item.setFlags(QtCore.Qt.ItemIsUserCheckable | QtCore.Qt.ItemIsEnabled)
            chk_item.setCheckState(QtCore.Qt.Unchecked)
            table.setItem(row, 0, chk_item)

            # data columns
            table.setItem(
                row,
                1,
                QtWidgets.QTableWidgetItem(dateEdit.date().toString("yyyy-MM-dd")),
            )
            table.setItem(
                row, 2, QtWidgets.QTableWidgetItem(categoryCombo.currentText())
            )
            table.setItem(
                row, 3, QtWidgets.QTableWidgetItem(accountCombo.currentText())
            )
            table.setItem(row, 4, QtWidgets.QTableWidgetItem(f"$ {amount:,.2f}"))
            table.setItem(row, 5, QtWidgets.QTableWidgetItem(notesEdit.toPlainText()))

            # action buttons
            make_row_buttons(row)

            # TODO: here is where you hook in your ORM:
            # from .entities import Expense
            # expense = Expense(
            #     date=dateEdit.date().toPython(),

            statusLabel.setText("Expense added")
            clear_form()

        return page

    # ----- Detail windows -----

    def show_categories_detail(self):
        dlg = DetailWindow(
            "All Categories",
            self.category_items,
            period="Last Week",
            parent=self,
        )
        dlg.exec()

    def show_history_detail(self):
        dlg = DetailWindow(
            "All Transactions",
            self.history_items,
            period="Last Week",
            parent=self,
        )
        dlg.exec()

    def show_upcoming_detail(self):
        # convert to (primary, secondary) for DetailWindow
        items = [
            (name, f"{subtitle} · {amount}")
            for (name, subtitle, amount) in self.upcoming_items
        ]
        dlg = DetailWindow(
            "Upcoming Payments",
            items,
            period="Next 30 days",
            parent=self,
        )
        dlg.exec()

    def show_goals_detail(self):
        items = [
            (name, f"${current:,.2f} of ${target:,.2f}")
            for (name, current, target) in self.goal_items
        ]
        dlg = DetailWindow(
            "Saving Goals",
            items,
            period="All goals",
            parent=self,
        )
        dlg.exec()

    def create_help_page(self, title):
        page = QtWidgets.QFrame()
        page.setObjectName("mainArea")
        layout = QtWidgets.QVBoxLayout(page)
        layout.setContentsMargins(18, 18, 18, 18)
        label = QtWidgets.QLabel(title)
        label.setObjectName("pageTitle")
        layout.addWidget(label)
        placeholder = QtWidgets.QLabel(
            f"{title} page content goes here (tables, forms, etc.)"
        )
        placeholder.setStyleSheet("color: #8f97c5;")
        layout.addWidget(placeholder)
        layout.addStretch()
        btn = QtWidgets.QPushButton("Visit Support Website")
        btn.setObjectName("pillButtonActive")
        btn.clicked.connect(self.show_about_dialog)
        layout.addWidget(btn, alignment=Qt.AlignLeft)

        return page

    def show_about_dialog(self):
        dlg = AboutDialog(self)
        dlg.exec()

    # ----- Styles -----

    def apply_styles(self):
        self.setStyleSheet(
            """
            QMainWindow {
                background-color: #262b63;
            }
            #sidebar {
                background-color: #111436;
                border-radius: 18px;
            }
            #mainArea {
                background-color: #0e1131;
                border-radius: 24px;
            }
            #logo {
                font-size: 24px;
                font-weight: 700;
                color: white;
                background-color: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                                  stop:0 #5b7cfa, stop:1 #8f6bff);
                border-radius: 16px;
                min-height: 48px;
            }
            #navButton {
                color: #8f97c5;
                font-size: 10px;
                border: none;
                padding: 4px 0;
            }
            #navButton:hover, #navButton:checked {
                background-color: #222755;   /* full-width hover bar */
                border-radius: 16px;
            }            
            #navButton:checked {
                color: white;
            }
            #searchBox {
                background-color: #15183f;
                border-radius: 20px;
                padding: 8px 14px;
                border: 1px solid #202556;
                color: #cfd5ff;
            }
            #searchBox::placeholder {
                color: #6e74aa;
            }
            #pillButton, #pillButtonActive {
                border-radius: 18px;
                padding: 6px 14px;
                font-size: 11px;
                border: 1px solid #323765;
            }
            #pillButton {
                background-color: transparent;
                color: #a9b0e0;
            }
            #pillButtonActive {
                background-color: #655df5;
                color: white;
            }
            #avatar {
                background-color: qradialgradient(cx:0.3, cy:0.3, radius:0.8,
                                stop:0 #fdd886, stop:1 #f46b45);
                border-radius: 16px;
            }
            #profileName {
                color: #f2f3ff;
                font-size: 12px;
            }
            #pageTitle {
                font-size: 13px;
                letter-spacing: 2px;
                color: #7078b3;
                margin-top: 8px;
            }
            #card {
                background-color: #15183f;
                border-radius: 18px;
            }
            #cardTitle {
                font-size: 11px;
                color: #7d84c6;
            }
            #cardValue {
                font-size: 24px;
                font-weight: 600;
                color: #ffffff;
            }
            #cardValueSmall {
                font-size: 13px;
                font-weight: 500;
                color: #ffffff;
            }
            #cardSubtitle {
                font-size: 11px;
                color: #747bb5;
            }
            #itemTitle {
                font-size: 12px;
                color: #e7e9ff;
            }
            #itemSubtitle {
                font-size: 11px;
                color: #7a81c4;
            }

            /* dialogs in same theme */
            QDialog#detailDialog {
                background-color: #0e1131;
                border-radius: 18px;
            }
            QDialog#detailDialog QPushButton {
                background-color: #655df5;
                border-radius: 14px;
                padding: 4px 12px;
                color: white;
                border: none;
            }
            QDialog#detailDialog QPushButton:hover {
                background-color: #7b74ff;
            }

            /* link-like "Show more" */
            #showMoreLink {
                font-size: 11px;
                color: #a9b0e0;
                border: none;
                padding: 0;
            }
            #showMoreLink:hover {
                color: #ffffff;
                text-decoration: underline;
            }

            /* Upcoming payments */
            #upcomingIcon {
                border-radius: 14px;
                background-color: #222755;
            }
            #upcomingAmount {
                font-size: 12px;
                color: #e7e9ff;
            }

            /* Saving goals */
            #goalIcon {
                border-radius: 14px;
                background-color: #222755;
            }
            QProgressBar#goalProgress {
                border: 0px;
                border-radius: 5px;
                background-color: #15183f;
                height: 8px;
                text-visible: false;
            }
            QProgressBar#goalProgress::chunk {
                border-radius: 5px;
                background-color: #7b74ff;
            }

            /* window control buttons */
            #iconButton {
                background: transparent;
                border: none;
                font-size: 16px;
                color: #b1b6e5;
            }
            #iconButton:hover {
                color: white;
            }
            
            #winButton {
                border-left: 1px solid white;
                background: transparent;
            }
            #winButton:hover {
                background: #ff5c5c;
                color: white;
            }
            #winButtonClose {
                background-color: transparent;
            }
            #winButtonClose:hover {
                background-color: #ff5c5c;
                color: white;
            }       

            /* savings card specific */
            #savingCircle {
                background: transparent;
            }
            #savingMetricGreen {
                font-size: 11px;
                color: #23d3a3;   /* green */
            }
            #savingMetricRed {
                font-size: 11px;
                color: #ff5c7a;   /* pink/red */
            }

            /* ----- Transactions / forms ----- */
            #sectionTitle {
                font-size: 13px;
                font-weight: 600;
                color: #e7e9ff;
            }
            #fieldLabel {
                font-size: 11px;
                color: #7d84c6;
            }
            #statusLabel {
                font-size: 11px;
                color: #23d3a3;
            }

            #primaryButton {
                background-color: #655df5;
                border-radius: 16px;
                padding: 6px 16px;
                color: white;
                border: none;
                font-size: 11px;
            }
            #primaryButton:hover {
                background-color: #7b74ff;
            }

            #secondaryButton {
                background-color: transparent;
                border-radius: 16px;
                padding: 6px 16px;
                color: #a9b0e0;
                border: 1px solid #323765;
                font-size: 11px;
            }
            #secondaryButton:hover {
                background-color: #222755;
                color: white;
            }

            QLineEdit#fieldEdit,
            QComboBox#fieldEdit,
            QDateEdit#fieldEdit,
            QDoubleSpinBox#fieldEdit,
            QPlainTextEdit#notesEdit {
                background-color: #15183f;
                border-radius: 12px;
                padding: 6px 10px;
                border: 1px solid #202556;
                color: #cfd5ff;
                selection-background-color: #655df5;
            }

            QPlainTextEdit#notesEdit {
                min-height: 60px;
            }

            QComboBox#fieldEdit::drop-down {
                border: none;
            }

            QTableWidget#expensesTable {
                background-color: #15183f;
                border-radius: 12px;
                gridline-color: #202556;
                color: #e7e9ff;
            }
            QHeaderView::section {
                background-color: #111436;
                color: #a9b0e0;
                border: none;
                padding: 4px 6px;
                font-size: 11px;
            }
            QTableWidget::item:selected {
                background-color: #222755;
            }

            #rowActionButton,
            #rowActionButtonDelete {
                background: transparent;
                border: none;
                padding: 2px;
            }
            #rowActionButton:hover {
                background-color: #222755;
            }
            #rowActionButtonDelete:hover {
                background-color: #5b2230;
            }
        """
        )

    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            self._drag_pos = event.globalPosition().toPoint()
        super().mousePressEvent(event)

    def mouseMoveEvent(self, event):
        if event.buttons() & Qt.LeftButton:
            try:
                diff = event.globalPosition().toPoint() - self._drag_pos
                self.move(self.pos() + diff)
                self._drag_pos = event.globalPosition().toPoint()
            except AttributeError:
                pass
        super().mouseMoveEvent(event)

# ----- About Dialog -----
class AboutDialog(QtWidgets.QDialog):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("About FinFlow")
        self.setModal(True)
        self.resize(520, 420)

        layout = QtWidgets.QVBoxLayout(self)
        layout.setContentsMargins(16, 16, 16, 16)
        layout.setSpacing(12)

        title = QtWidgets.QLabel("FinFlow")
        title.setStyleSheet("font-size: 20px; font-weight: 600; color: #ffffff;")
        layout.addWidget(title)

        subtitle = QtWidgets.QLabel("Personal Budget Dashboard")
        subtitle.setStyleSheet("font-size: 12px; color: #aaaaaa;")
        layout.addWidget(subtitle)

        version = QtWidgets.QLabel("Version 1.0.0")
        version.setStyleSheet("font-size: 11px; color: #888888;")
        layout.addWidget(version)

        # Scrollable text area for licenses / attributions
        scroll = QtWidgets.QScrollArea()
        scroll.setWidgetResizable(True)
        layout.addWidget(scroll)

        inner = QtWidgets.QWidget()
        scroll.setWidget(inner)
        inner_layout = QtWidgets.QVBoxLayout(inner)
        inner_layout.setContentsMargins(0, 0, 0, 0)

        text = QtWidgets.QTextBrowser()
        text.setOpenExternalLinks(True)
        text.setStyleSheet("background: transparent; border: none;")
        text.setHtml(self._about_html())
        inner_layout.addWidget(text)

        # Close button
        button_box = QtWidgets.QDialogButtonBox(QtWidgets.QDialogButtonBox.Close)
        button_box.rejected.connect(self.reject)
        layout.addWidget(button_box)

        # Optional dark styling if your app uses a dark theme
        self.setStyleSheet(
            """
            QDialog {
                background-color: #0e1131;
            }
            QScrollArea {
                background-color: transparent;
                border: 1px solid #202556;
                border-radius: 8px;
            }
            QDialogButtonBox QPushButton {
                padding: 4px 12px;
                border-radius: 6px;
                background-color: #655df5;
                color: white;
                border: none;
            }
            QDialogButtonBox QPushButton:hover {
                background-color: #7b74ff;
            }
        """
        )

    def _about_html(self) -> str:
        # Edit anything you want here, this is just a sane starting point.
        return """
        <html>
        <body style="font-family: sans-serif; font-size: 11px;">
            <p>
                <b>FinFlow</b> is a personal budget dashboard application built with
                Qt / PySide6 and Python.
            </p>

            <p>
                &copy; {year} Your Name or Company. All rights reserved.
            </p>

            <hr>

            <h3>Third-party components</h3>

            <p>
                This application uses the following third-party libraries and assets:
            </p>

            <ul>
                <li><b>PySide6 / Qt</b> &mdash; Qt for Python runtime and widgets.</li>
                <li><b>Matplotlib</b> &mdash; for charts and data visualization.</li>
                <li><b>qtawesome</b> &mdash; helper for using icon fonts in Qt.</li>
                <li><b>Font Awesome Free</b> &mdash; icon font used via qtawesome and
                    embedded TTF files.</li>
            </ul>

            <p>
                Qt / PySide6 is licensed under the GNU Lesser General Public License (LGPL).
                Matplotlib and qtawesome are provided under permissive open-source licenses.
                Please refer to the respective project documentation for full details.
            </p>

            <hr>

            <h3>Font Awesome Free</h3>

            <p>
                This app uses <b>Font Awesome Free</b> icons by Fonticons, Inc., both via
                the <code>qtawesome</code> Python package and by embedding the Font Awesome
                Free TTF files in the application.
            </p>

            <p style="margin-top: 4px;">
                Font Awesome&reg; is a trademark of Fonticons, Inc.
                For full license terms and icon set details, visit
                <a href="https://fontawesome.com">https://fontawesome.com</a>.
            </p>

            <hr>

            <h3>Notice</h3>

            <p>
                This About dialog and attribution text are provided as a convenience and do
                not constitute legal advice. If you plan to distribute or sell this software,
                please review all third-party licenses and consult a legal professional if
                necessary.
            </p>
        </body>
        </html>
        """.format(
            year=QtCore.QDate.currentDate().year()
        )


def main():
    app = QtWidgets.QApplication(sys.argv)
    
    win = MainWindow()
    win.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
