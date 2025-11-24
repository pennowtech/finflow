// LineChartCard.qml
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
    property string subtitle: ""
    property color seriesColor: "#7c3aed"
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

        Text {
            text: root.subtitle
            font.pixelSize: 11
            color: "#747bb5"
        }

        ChartView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            backgroundColor: "transparent"
            antialiasing: true
            legend.visible: false

            ValueAxis { id: xAxis; min: 1; max: Math.max(1, root.sampleValues.length); visible: false }
            ValueAxis { id: yAxis; min: 0; max: Math.max.apply(Math, root.sampleValues.concat([1])); visible: false }

            LineSeries {
                axisX: xAxis
                axisY: yAxis
                color: root.seriesColor
                width: 2

                Component.onCompleted: {
                    clear()
                    for (var i = 0; i < root.sampleValues.length; ++i)
                        append(i + 1, root.sampleValues[i])
                }
            }
        }
    }
}
