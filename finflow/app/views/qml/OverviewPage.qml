// OverviewPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.15
import QmlControls


Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    // passed from main.qml: iconFontFamily: faSolid.name
    property string iconFontFamily: ""

    ColumnLayout {
        anchors.fill: parent
        spacing: 18

        // ─────────────────────────────────────────
        // Header row
        // ─────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Overview"
                    font.pixelSize: 24
                    font.bold: true
                    color: theme.color.textPrimary
                }

                Text {
                    text: "Your financial snapshot"
                    font.pixelSize: 13
                    color: theme.color.textSecondary
                }
            }

            // Date / period selector placeholder (right side)
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                radius: 999
                color: theme.color.cardBg
                border.color: theme.color.textMuted
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    Text {
                        text: "\uf073"    // calendar icon
                        font.family: iconFontFamily
                        font.pixelSize: 14
                        color: theme.color.textSecondary
                    }

                    Text {
                        text: "Last 30 days"
                        font.pixelSize: 13
                        color: theme.color.textSecondary
                    }
                }
            }
        }

        // ─────────────────────────────────────────
        // Top summary cards (Balance / Income / Expense)
        // ─────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 18

            // Total balance
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                height: 110
                radius: 18
                color: theme.color.cardBg

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    Row {
                        spacing: 8
                        Text {
                            text: "\uf555" // piggy-bank
                            font.family: iconFontFamily
                            font.pixelSize: 18
                            color: Theme.color.accentPrimary 
                        }
                        Text {
                            text: "Total Balance"
                            font.pixelSize: 13
                            color: Theme.color.textSecondary
                        }
                    }

                    Text {
                        text: "€ 12,430.75"
                        font.pixelSize: 22
                        font.bold: true
                        color: Theme.color.textPrimary
                    }

                    Text {
                        text: "+ € 420.10 vs last month"
                        font.pixelSize: 12
                        color: theme.color.textMuted
                    }
                }
            }

            // Income
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                height: 110
                radius: 18
                color: theme.color.cardBg

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    Row {
                        spacing: 8
                        Text {
                            text: "\uf201" // chart-line
                            font.family: iconFontFamily
                            font.pixelSize: 18
                            color: Theme.color.accentPrimary
                        }
                        Text {
                            text: "Income"
                            font.pixelSize: 13
                            color: theme.color.textSecondary
                        }
                    }

                    Text {
                        text: "€ 4,200.00"
                        font.pixelSize: 20
                        font.bold: true
                        color: theme.color.textPrimary
                    }

                    Text {
                        text: "+ 12% vs last month"
                        font.pixelSize: 12
                        color: Theme.color.textMuted
                    }
                }
            }

            // Expenses
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                height: 110
                radius: 18
                color: theme.color.cardBg

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    Row {
                        spacing: 8
                        Text {
                            text: "\uf555" // reuse piggy-bank or change to another FA symbol
                            font.family: iconFontFamily
                            font.pixelSize: 18
                            color: Theme.color.accentPrimary
                        }
                        Text {
                            text: "Expenses"
                            font.pixelSize: 13
                            color: Theme.color.textSecondary
                        }
                    }

                    Text {
                        text: "€ 2,870.50"
                        font.pixelSize: 20
                        font.bold: true
                        color: Theme.color.textPrimary
                    }

                    Text {
                        text: "- 5% vs last month"
                        font.pixelSize: 12
                        color: Theme.color.textMuted
                    }
                }
            }
        }

        // ─────────────────────────────────────────
        // Main content row: Chart + Recent transactions
        // ─────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 18

            // Left: chart card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 2
                radius: 18
                color: Theme.color.cardBg

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Cashflow"
                            font.pixelSize: 16
                            font.bold: true
                            color: Theme.color.textPrimary
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            color: "transparent"
                        }

                        Text {
                            text: "This month"
                            font.pixelSize: 12
                            color: Theme.color.textSecondary
                        }
                    }

                    ChartView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        antialiasing: true
                        backgroundColor: "transparent"
                        legend.visible: false

                        ValueAxis {
                            id: axisX
                            min: 1
                            max: 12
                            labelsVisible: false
                        }

                        ValueAxis {
                            id: axisY
                            min: 0
                            max: 5000
                            labelsVisible: false
                        }

                        LineSeries {
                            axisX: axisX
                            axisY: axisY

                            XYPoint { x: 1;  y:  800 }
                            XYPoint { x: 2;  y: 1100 }
                            XYPoint { x: 3;  y: 1400 }
                            XYPoint { x: 4;  y: 1300 }
                            XYPoint { x: 5;  y: 1700 }
                            XYPoint { x: 6;  y: 2100 }
                            XYPoint { x: 7;  y: 2000 }
                            XYPoint { x: 8;  y: 2600 }
                            XYPoint { x: 9;  y: 2400 }
                            XYPoint { x:10;  y: 3000 }
                            XYPoint { x:11;  y: 2800 }
                            XYPoint { x:12;  y: 3200 }
                        }
                    }
                }
            }

            // Right: Recent transactions
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                radius: 18
                color: theme.color.cardBg

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Recent Transactions"
                            font.pixelSize: 16
                            font.bold: true
                            color: theme.color.textPrimary
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            color: "transparent"
                        }

                        Text {
                            text: "View all"
                            font.pixelSize: 12
                            color: Theme.color.accentPrimary
                        }
                    }

                    // Scrollable list
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 6

                        model: ListModel {
                            ListElement { title: "Groceries";       category: "Food";       amount: -65.90;  time: "Today" }
                            ListElement { title: "Salary";          category: "Income";     amount: 2100.00; time: "Yesterday" }
                            ListElement { title: "Netflix";         category: "Subscription";amount: -12.99; time: "Yesterday" }
                            ListElement { title: "Coffee";          category: "Food";       amount: -3.50;  time: "Mon" }
                            ListElement { title: "Rent";            category: "Housing";    amount: -950.00; time: "1 Nov" }
                        }

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 52
                            radius: 12
                            color: Qt.rgba(1, 1, 1, hovered ? 0.05 : 0.0)

                            property bool hovered: false

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.hovered = true
                                onExited:  parent.hovered = false
                            }

                            Row {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 16
                                    color: theme.color.mainBg

                                    Text {
                                        anchors.centerIn: parent
                                        text: title.length > 0 ? title[0].toUpperCase() : ""
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: theme.color.textPrimary
                                    }
                                }

                                Column {
                                    width: parent.width * 0.55
                                    spacing: 2

                                    Text {
                                        text: title
                                        font.pixelSize: 13
                                        color: theme.color.textPrimary
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: category + " · " + time
                                        font.pixelSize: 11
                                        color: theme.color.textMuted
                                        elide: Text.ElideRight
                                    }
                                }

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 1
                                    height: 26
                                    color: theme.color.mainBg
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: (amount < 0 ? "- € " : "+ € ") + Math.abs(amount).toFixed(2)
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: amount < 0 ? Theme.color.textSecondary : Theme.color.accentPrimary
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
