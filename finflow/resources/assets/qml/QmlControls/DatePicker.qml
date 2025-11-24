// DatePicker.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15


Control {
    id: root
    implicitHeight: 32
    implicitWidth: 200

    // PUBLIC API
    property string faFamily: ""                // FontAwesome for inner calendar
    property string selectionMode: "single"     // or "range"

    // Value for single selection
    property date value: new Date()

    // Values for range
    property date rangeStart: value
    property date rangeEnd: value

    // Expose calendar for configuration (expenseMap, categoryMap, monthsVisible, etc.)
    property alias calendar: cal

    // For formatting the display text
    property string displayFormat: "yyyy-MM-dd"

    // displayed text
    function displayText() {
        if (selectionMode === "single") {
            return Qt.formatDate(value, displayFormat);
        } else {
            return Qt.formatDate(rangeStart, displayFormat)
                 + " – "
                 + Qt.formatDate(rangeEnd, displayFormat);
        }
    }

    background: Rectangle {
        radius: Theme.radius.sm
        color: Theme.color.mainBg
        border.color: Theme.color.sidebarBg
        border.width: 1
    }

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.sm
        spacing: Theme.spacing.sm

        Text {
            Layout.fillWidth: true
            text: displayText()
            elide: Text.ElideRight
            color: Theme.color.textSecondary
            font.pixelSize: Theme.text.baseSize
            font.family: Theme.text.familyPrimary
        }

        Text {
            text: "\uf073"      // fa-calendar-alt
            font.family: root.faFamily
            font.pixelSize: Theme.text.baseSize
            color: Theme.color.textSecondary
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (popup.visible) popup.close()
            else popup.open()
        }
    }

    Popup {
        id: popup
        modal: false
        focus: true
        padding: 0
        width: 360
        height: 380
        y: root.height + 4
        x: 0
        parent: root       // keeps it visually attached

        background: Rectangle {
            radius: Theme.radius.lg
            color: "transparent"
        }
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape

        Calendar {
            id: cal
            anchors.fill: parent
            faFamily: root.faFamily
            selectionMode: root.selectionMode

            onDateSelected: function(d) {
                if (selectionMode === "single") {
                    root.value = d;
                    // close after picking in single mode
                    popup.close();
                }
            }

            onRangeChanged: function(s, e) {
                if (selectionMode === "range") {
                    root.rangeStart = s;
                    root.rangeEnd   = e;
                    // optional: close when second date picked
                    if (!isSameDate(s, e)) {
                        popup.close();
                    }
                }
            }

            // helper for single mode close logic
            function isSameDate(a, b) {
                return a.getDate() === b.getDate()
                    && a.getMonth() === b.getMonth()
                    && a.getFullYear() === b.getFullYear();
            }
        }
    }
}
