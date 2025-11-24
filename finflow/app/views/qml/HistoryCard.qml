// HistoryCard.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    radius: 16
    color: "#11194c"
    clip: true

    // let layouts know how big this item wants to be
    implicitWidth: 320
    implicitHeight: contentLayout.implicitHeight + 32   // margins

    // === Public API ===
    property alias title: titleText.text
    property var model               // supplied by the caller
    property int maxRows: 4
    property int rowHeight: 60
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true

            Text {
                id: titleText
                text: "History Transaction"
                color: "#ffffff"
                font.pixelSize: 18
                font.bold: true
                Layout.fillWidth: true
            }

            Text {
                text: "⋯"
                color: "#ffffff"
                font.pixelSize: 20
                horizontalAlignment: Text.AlignRight
            }
        }

        // List of transactions
        ListView {
            id: listView
            Layout.fillWidth: true
            clip: true
            interactive: false
            spacing: 8

            model: root.model

            // only show whole rows
            height: Math.min(root.maxRows, count) * root.rowHeight

            delegate: RowLayout {
                width: listView.width
                height: root.rowHeight

                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: width / 2
                    color: "#ffffff"
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: name
                        color: "#ffffff"
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: date
                        color: "#9aa0d0"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                Text {
                    text: amount
                    color: "#ffffff"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                }
            }
        }
    }
}
