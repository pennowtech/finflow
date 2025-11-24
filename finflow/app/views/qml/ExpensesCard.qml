// ExpensesCard.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.15

Rectangle {
    id: root
    radius: 16
    clip: true

    // Card background gradient
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#141b5a" }
        GradientStop { position: 1.0; color: "#6b1f7b" }
    }

    implicitWidth: 320
    implicitHeight: 220
    Layout.fillWidth: true
    Layout.fillHeight: true

    // ==== Public API ====
    // model: ListModel { ListElement { day: "Mon"; value: 200 } ... }
    property var model
    property string title: "Expenses"
    property string periodLabel: "Last Week"
    property string totalText: "$0.00"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8

        // HEADER
        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: root.title
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    text: root.periodLabel
                    color: "#9aa0d0"
                    font.pixelSize: 11
                }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: root.totalText
                    color: "#ffffff"
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignRight
                }
                Text {
                    text: "Total"
                    color: "#9aa0d0"
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignRight
                }
            }
        }



        // Mouse interaction (move highlight)
        MouseArea {
            anchors.fill: chart
            hoverEnabled: true

            onPositionChanged: {
                if (!root.model || root.model.count === 0)
                    return;

                var valuePoint = chart.mapToValue(Qt.point(mouse.x, mouse.y),
                                                  splineSeries);
                var idx = Math.round(valuePoint.x);
                idx = Math.max(0, Math.min(idx, root.model.count - 1));
                if (idx !== chart.currentIndex)
                    chart.currentIndex = idx;
            }
        }

        // Highlight item is outside chart but follows its coordinates
        Item {
            id: highlight
            visible: false

            Behavior on x {
                NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
            }
            Behavior on y {
                NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
            }

            Rectangle {
                id: labelBox
                anchors.horizontalCenter: dot.horizontalCenter
                anchors.bottom: dot.top
                anchors.bottomMargin: 6
                radius: 4
                color: "#ff5b99"
                border.color: "transparent"

                Text {
                    id: highlightLabel
                    color: "#ffffff"
                    font.pixelSize: 11
                }
            }

            Rectangle {
                id: dot
                width: 14
                height: 14
                radius: 7
                color: "#ff5b99"
                border.color: "#ffffff"
                border.width: 2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // bottom day labels
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: root.model ? root.model : 0
                Text {
                    Layout.fillWidth: true
                    text: day
                    horizontalAlignment: Text.AlignHCenter
                    color: "#ffffff"
                    opacity: 0.7
                    font.pixelSize: 11
                }
            }
        }
    }

    // update whenever caller changes the model
    onModelChanged: chart.rebuild()
}
