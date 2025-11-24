// MetricCard.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    radius: 18
    color: "#15183f"

    property string title: ""
    property string value: ""
    property string subtitle: ""

    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 6

        Text {
            text: root.title
            font.pixelSize: 11
            color: "#7d84c6"
        }

        Text {
            text: root.value
            font.pixelSize: 24
            font.bold: true
            color: "white"
        }

        Item { Layout.fillHeight: true }

        Text {
            text: root.subtitle
            font.pixelSize: 11
            color: "#747bb5"
        }
    }
}
