// Calendar.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    radius: Theme.radius.lg
    color: Theme.color.cardBg
    width: 360
    height: 380

    // ========== PUBLIC API ==========

    property string faFamily: ""          // FontAwesome family for icons

    // "single" or "range"
    property string selectionMode: "range"

    // For single selection (and generally the last clicked date)
    property date selectedDate: new Date()

    // Range selection
    property date rangeStart: selectedDate
    property date rangeEnd:   selectedDate
    property bool rangeEnabled: selectionMode === "range"

    // Multi-month view (1–3)
    property int monthsVisible: 1

    // Expense heatmap: "yyyy-MM-dd" -> Number
    property var expenseMap: ({})
    property real minExpense: 0
    property real maxExpense: 0

    // Category dots: "yyyy-MM-dd" -> [ "#color1", "#color2", ... ]
    property var categoryMap: ({})

    signal dateSelected(date date)
    signal rangeChanged(date start, date end)

    // ===== SINGLE SOURCE OF TRUTH FOR THE VISIBLE MONTH =====
    // Visible month is stored as a date (always day=1)
    property date visibleDate: selectedDate   // visible month
    property int currentYear:  visibleDate.getFullYear()
    property int currentMonth: visibleDate.getMonth()   // 0–11

    // When selectedDate changes from outside, sync visible month
    onSelectedDateChanged: {
        visibleDate = new Date(selectedDate.getFullYear(),
                               selectedDate.getMonth(),
                               1)
    }

    // Common column width (weekday header + grid cells)
    property real columnWidth: (width - 2 * Theme.spacing.xl - 6 * Theme.spacing.xs) / 7

    // ========== HELPERS ==========

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate();
    }

    // Monday-first offset: Mon=0..Sun=6
    function firstDayOffset(year, month) {
        let d = new Date(year, month, 1).getDay(); // 0=Sun
        return (d === 0 ? 6 : d - 1);
    }

    // Safe key builder – NO Qt.formatDate() here to avoid errors
    function dateKey(d) {
        if (!d)
            return "";
        let y = d.getFullYear();
        let m = d.getMonth() + 1;
        let day = d.getDate();
        let mm = (m < 10 ? "0" + m : "" + m);
        let dd = (day < 10 ? "0" + day : "" + day);
        return y + "-" + mm + "-" + dd;
    }

    function expenseForDate(d) {
        let key = dateKey(d);
        let v = expenseMap[key];
        if (typeof v === "number")
            return v;
        return 0;
    }

    function recomputeExpenseRange() {
        let first = true;
        let minV = 0;
        let maxV = 0;
        for (var k in expenseMap) {
            let v = expenseMap[k];
            if (typeof v === "number") {
                if (first) {
                    minV = v; maxV = v; first = false;
                } else {
                    if (v < minV) minV = v;
                    if (v > maxV) maxV = v;
                }
            }
        }
        if (first) {
            minExpense = 0;
            maxExpense = 0;
        } else {
            minExpense = minV;
            maxExpense = maxV;
        }
    }

    onExpenseMapChanged: recomputeExpenseRange()
    Component.onCompleted: recomputeExpenseRange()

    function isSameDate(a, b) {
        if (!a || !b) return false;
        return a.getDate() === b.getDate()
            && a.getMonth() === b.getMonth()
            && a.getFullYear() === b.getFullYear();
    }

    function inRange(d) {
        if (!rangeEnabled || selectionMode !== "range") return false;
        let s = rangeStart;
        let e = rangeEnd;
        if (!s || !e) return false;
        if (e < s) { let tmp = s; s = e; e = tmp; }
        return d >= s && d <= e;
    }

    function handleDateClick(d) {
        selectedDate = d;

        // keep visible month in sync with clicked date
        visibleDate = new Date(d.getFullYear(), d.getMonth(), 1);

        if (selectionMode === "single") {
            rangeStart = d;
            rangeEnd   = d;
        } else {
            if (!rangeStart || !rangeEnd || isSameDate(rangeStart, rangeEnd)) {
                rangeStart = d;
                rangeEnd   = d;
            } else {
                if (d < rangeStart) {
                    rangeEnd   = rangeStart;
                    rangeStart = d;
                } else {
                    rangeEnd = d;
                }
            }
        }

        dateSelected(d);
        rangeChanged(rangeStart, rangeEnd);
    }

    function applyMonthDelta(delta) {
        // Change only via visibleDate so everything stays in sync
        visibleDate = new Date(currentYear, currentMonth + delta, 1);
    }

    function goPrevMonth() {
        applyMonthDelta(-1);
    }

    function goNextMonth() {
        applyMonthDelta(1);
    }

    function monthName(year, monthIndex) {
        // monthIndex 0–11
        return Qt.formatDate(new Date(year, monthIndex, 1), "MMMM");
    }

    // ========== Month / Year selectors (popups) ==========

    Popup {
        id: monthPopup
        modal: false
        focus: true
        padding: 0
        y: headerRow.height + Theme.spacing.sm
        x: monthLabel.x
        width: 150
        height: 240
        background: Rectangle {
            radius: Theme.radius.lg
            color: Theme.color.cardBg
            border.color: Theme.color.textMuted
            border.width: 1
        }
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape

        ListView {
            anchors.fill: parent
            clip: true
            model: 12
            delegate: Rectangle {
                width: ListView.view ? ListView.view.width : 0
                height: 32
                color: index === root.currentMonth ? Theme.color.sidebarBg : "transparent"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // update visible month via visibleDate
                        root.visibleDate = new Date(root.currentYear, index, 1);
                        monthPopup.close();
                    }
                    hoverEnabled: true
                    onEntered: if (index !== root.currentMonth) parent.color = "#15183f"
                    onExited:  if (index !== root.currentMonth) parent.color = "transparent"
                }

                Text {
                    anchors.centerIn: parent
                    text: monthName(root.currentYear, index)
                    color: index === root.currentMonth ? Theme.color.textPrimary : Theme.color.textSecondary
                    font.pixelSize: Theme.text.baseSize
                    font.family: Theme.text.familyPrimary
                }
            }
        }
    }

    Popup {
        id: yearPopup
        modal: false
        focus: true
        padding: 0
        y: headerRow.height + Theme.spacing.sm
        x: yearLabel.x
        width: 120
        height: 260
        background: Rectangle {
            radius: Theme.radius.lg
            color: Theme.color.cardBg
            border.color: Theme.color.textMuted
            border.width: 1
        }
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape

        // simple year window: currentYear-10 .. currentYear+10
        property int yearStart: root.currentYear - 10
        property int yearCount: 21

        ListView {
            anchors.fill: parent
            clip: true
            model: yearPopup.yearCount

            delegate: Rectangle {
                width: ListView.view ? ListView.view.width : 0
                height: 32

                property int yearValue: yearPopup.yearStart + index
                color: yearValue === root.currentYear ? Theme.color.sidebarBg : "transparent"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // update visible month via visibleDate
                        root.visibleDate = new Date(yearValue, root.currentMonth, 1);
                        yearPopup.close();
                    }
                    hoverEnabled: true
                    onEntered: if (yearValue !== root.currentYear) parent.color = "#15183f"
                    onExited:  if (yearValue !== root.currentYear) parent.color = "transparent"
                }

                Text {
                    anchors.centerIn: parent
                    text: yearValue
                    color: yearValue === root.currentYear ? Theme.color.textPrimary : Theme.color.textSecondary
                    font.pixelSize: Theme.text.baseSize
                    font.family: Theme.text.familyPrimary
                }
            }

            Component.onCompleted: {
                var idx = root.currentYear - yearPopup.yearStart;
                if (idx >= 0 && idx < count) {
                    currentIndex = idx;
                    positionViewAtIndex(idx, ListView.Center)
                }
            }
        }
    }

    // ========== Layout ==========

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xl
        spacing: Theme.spacing.xl

        // Header row (month/year + nav)
        RowLayout {
            id: headerRow
            Layout.fillWidth: true

            // Prev
            Rectangle {
                radius: Theme.radius.sm
                color: "transparent"
                Layout.preferredWidth: 32      // <<< add
                Layout.preferredHeight: 32     // <<< add

                Text {
                    anchors.centerIn: parent
                    text: "\uf053"
                    font.family: root.faFamily
                    font.pixelSize: Theme.text.baseSize
                    color: Theme.color.textSecondary
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: goPrevMonth()
                    onEntered: parent.color = Theme.color.sidebarBg
                    onExited: parent.color = "transparent"
                }
            }

            Item { Layout.fillWidth: true }

            Row {
                spacing: 4
                // Month label (clickable)
                Text {
                    id: monthLabel
                    text: monthName(root.currentYear, root.currentMonth)
                    color: Theme.color.textPrimary
                    font.pixelSize: Theme.text.lSize
                    font.family: Theme.text.familyPrimary
                    font.weight: Theme.text.weightSemibold

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (monthPopup.visible) monthPopup.close()
                            else monthPopup.open()
                        }
                        onEntered: parent.color = Theme.color.accentSecondary
                        onExited: parent.color = Theme.color.textPrimary
                    }
                }

                Text {
                    text: " "
                }

                // Year label (clickable)
                Text {
                    id: yearLabel
                    text: root.currentYear
                    color: Theme.color.textMuted
                    font.pixelSize: Theme.text.baseSize
                    font.family: Theme.text.familyPrimary
                    font.weight: Theme.text.weightMedium

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (yearPopup.visible) yearPopup.close()
                            else yearPopup.open()
                        }
                        onEntered: parent.color = Theme.color.accentSecondary
                        onExited: parent.color = Theme.color.textMuted
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Next
            Rectangle {
                radius: Theme.radius.sm
                color: "transparent"
                Layout.preferredWidth: 32      // <<< add
                Layout.preferredHeight: 32     // <<< add

                Text {
                    anchors.centerIn: parent
                    text: "\uf054"
                    font.family: root.faFamily
                    font.pixelSize: Theme.text.baseSize
                    color: Theme.color.textSecondary
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: goNextMonth()
                    onEntered: parent.color = Theme.color.sidebarBg
                    onExited: parent.color = "transparent"
                }
            }
        }

        // Weekday headers
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
                Text {
                    text: modelData
                    font.pixelSize: Theme.text.sSize
                    font.family: Theme.text.familyPrimary
                    color: index >= 5 ? Theme.color.accentDanger : Theme.color.textMuted
                    Layout.preferredWidth: root.columnWidth
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // Multi-month area
        Item {
            id: monthsWrapper
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            RowLayout {
                id: monthsRow
                anchors.fill: parent
                spacing: Theme.spacing.lg

                Repeater {
                    model: monthsVisible

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: Theme.spacing.sm

                        property int viewOffset: index

                        // Optional per-month small label when multiple
                        Text {
                            visible: monthsVisible > 1
                            text: Qt.formatDate(
                                      new Date(root.currentYear,
                                               root.currentMonth + viewOffset,
                                               1),
                                      "MMM yyyy")
                            color: Theme.color.textMuted
                            font.pixelSize: Theme.text.sSize
                            font.family: Theme.text.familyPrimary
                            font.weight: Theme.text.weightMedium
                        }

                        GridLayout {
                            id: grid
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            rows: 6
                            columns: 7
                            rowSpacing: Theme.spacing.xs
                            columnSpacing: Theme.spacing.xs

                            property int year: new Date(root.currentYear,
                                                        root.currentMonth + parent.viewOffset,
                                                        1).getFullYear()
                            property int month: new Date(root.currentYear,
                                                         root.currentMonth + parent.viewOffset,
                                                         1).getMonth()
                            property int totalDays: daysInMonth(year, month)
                            property int offset: firstDayOffset(year, month)

                            Repeater {
                                model: 42   // 6 weeks * 7 days

                                Rectangle {
                                    width: root.columnWidth
                                    height: 46
                                    radius: Theme.radius.md
                                    color: "transparent"

                                    property int dayNumber: index - grid.offset + 1
                                    property bool validDay: dayNumber >= 1 && dayNumber <= grid.totalDays
                                    property date cellDate: new Date(grid.year, grid.month, dayNumber)

                                    property bool isSelectedStart: validDay ? isSameDate(cellDate, rangeStart) : false
                                    property bool isSelectedEnd:   validDay ? isSameDate(cellDate, rangeEnd)   : false
                                    property bool isSelected:      validDay && (isSelectedStart || isSelectedEnd)
                                    property bool isInRange:       validDay ? inRange(cellDate) : false

                                    property bool isToday: {
                                        if (!validDay) return false;
                                        var now = new Date();
                                        return now.getDate() === cellDate.getDate()
                                            && now.getMonth() === cellDate.getMonth()
                                            && now.getFullYear() === cellDate.getFullYear();
                                    }

                                    property bool isWeekend: validDay &&
                                        (cellDate.getDay() === 0 || cellDate.getDay() === 6)

                                    Rectangle {
                                        id: rangeBg
                                        anchors.fill: parent
                                        radius: Theme.radius.md
                                        color: Theme.color.accentPrimary
                                        opacity: {
                                            if (!validDay) return 0;
                                            if (isSelected) return 1.0;
                                            if (selectionMode === "range" && isInRange)  return 0.35;

                                            // heatmap behind normal days
                                            let v = expenseForDate(parent.cellDate);
                                            if (v <= 0 || root.maxExpense <= 0) return 0;
                                            let t = (v - root.minExpense) / (root.maxExpense - root.minExpense || 1);
                                            t = Math.max(0, Math.min(1, t));
                                            return 0.15 + 0.45 * t;
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: validDay
                                        hoverEnabled: true
                                        onClicked: handleDateClick(parent.cellDate)
                                        onEntered: {
                                            if (validDay && !parent.isSelected && !parent.isInRange)
                                                parent.opacity = 0.85;
                                        }
                                        onExited: parent.opacity = 1.0
                                    }

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: Theme.spacing.xs
                                        spacing: 0

                                        Item {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            height: parent.height - 16
                                            width: parent.width

                                            Text {
                                                anchors.centerIn: parent
                                                text: validDay ? dayNumber : ""
                                                font.pixelSize: Theme.text.baseSize
                                                font.family: Theme.text.familyNumeric
                                                font.weight: parent.parent.isToday
                                                             ? Theme.text.weightSemibold
                                                             : Theme.text.weightRegular
                                                color: {
                                                    if (!validDay)                 return "transparent";
                                                    if (parent.parent.isSelected)  return Theme.color.textPrimary;
                                                    if (parent.parent.isToday)     return Theme.color.accentSecondary;
                                                    if (parent.parent.isWeekend)   return Theme.color.accentDanger;
                                                    return Theme.color.textSecondary;
                                                }
                                            }
                                        }

                                        // Category dots
                                        Row {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            spacing: 2

                                            Repeater {
                                                model: {
                                                    if (!validDay) return [];
                                                    let key = dateKey(parent.parent.cellDate);
                                                    return root.categoryMap[key] || [];
                                                }

                                                Rectangle {
                                                    width: 6
                                                    height: 6
                                                    radius: 3
                                                    color: modelData
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
