// SavingsCard.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    radius: 18
    color: "#15183f"

    property real current: 0
    property real target: 1

    Layout.fillWidth: true
    Layout.fillHeight: true

    readonly property real ratio: target > 0 ? Math.min(1, current / target) : 0
    readonly property int achievedPct: Math.round(ratio * 100)
    readonly property int remainingPct: Math.max(0, 100 - achievedPct)

    RowLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: "Saving"
                font.pixelSize: 11
                color: "#7d84c6"
            }

            Text {
                text: "Last Week"
                font.pixelSize: 11
                color: "#747bb5"
            }

            Text {
                text: "$ " + Number(root.current).toLocaleString(Qt.locale(), 'f', 2)
                font.pixelSize: 24
                font.bold: true
                color: "white"
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                spacing: 16

                Text {
                    text: "↑ " + root.achievedPct + "% Achieved"
                    font.pixelSize: 11
                    color: "#23d3a3"
                }

                Text {
                    text: "↓ " + root.remainingPct + "% Left"
                    font.pixelSize: 11
                    color: "#ff5c7a"
                }
            }
        }


    }
}
