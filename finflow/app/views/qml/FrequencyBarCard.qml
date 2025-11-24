// FrequencyBarCard.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.15

Rectangle {
    id: root
    radius: 18
    color: "#15183f"

    property string title: ""
    property string valueText: ""
    property var sampleValues: [0]

    Layout.fillWidth: true
    Layout.preferredHeight: 150

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: root.title
                font.pixelSize: 11
                color: "#7d84c6"
            }

            Item { Layout.fillWidth: true }

            Text {
                text: root.valueText
                font.pixelSize: 13
                color: "white"
            }
        }

        ChartView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            backgroundColor: "transparent"
            legend.visible: false
            antialiasing: true

            ValueAxis { id: xAxis; min: 0; max: root.sampleValues.length + 1; visible: false }
            ValueAxis { id: yAxis; min: 0; max: Math.max.apply(Math, root.sampleValues.concat([1])); visible: false }

            BarSeries {
                axisX: xAxis
                axisY: yAxis

                BarSet {
                    id: set
                    color: "#5b7cfa"

                    Component.onCompleted: {
                        clear()
                        for (var i = 0; i < root.sampleValues.length; ++i)
                            append(root.sampleValues[i])
                    }
                }
            }
        }
    }
}
