// PopularCategoryCard.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts

import QmlControls

Rectangle {
    id: root
    radius: Theme.radius.lg
    color: Theme.color.cardBg

    // FontAwesome family – you can override from OverviewPage
    property string iconFontFamily: Theme.text.iconFontFamily

    // Data: name + numeric value
    property var categories: [
        { "name": "Housing",        "value": 1200.0 },
        { "name": "Food",           "value": 460.0  },
        { "name": "Entertainment",  "value": 320.5  },
        { "name": "Transportation", "value": 249.5  },
        { "name": "Other",          "value": 140.0  },
        { "name": "Subscriptions",  "value": 60.0   }
    ]

    // Colors for the slices (using your theme where it’s safe)
    property var categoryColors: [
        Theme.color.accentSecondary,
        Theme.color.accentSuccess,
        Theme.color.accentDanger,
        Theme.color.accentWarning,
        "#a855f7",               // extra accent
        Theme.color.accentInfo
    ]

    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.md

        // Header: title + "more" icon
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Popular Category"
                font.pixelSize: Theme.text.sSize
                color: Theme.color.textSecondary
            }

            Item { Layout.fillWidth: true }

            Text {
                id: moreIcon
                text: "\uf141"   // fa-ellipsis-h
                font.family: iconFontFamily
                font.pixelSize: Theme.text.baseSize
                color: Theme.color.textSecondary

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: moreIcon.color = Theme.color.textPrimary
                    onExited:  moreIcon.color = Theme.color.textSecondary
                    // onClicked: emit signal from parent if you want
                }
            }
        }

        // Body: left list + right pie
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.spacing.md

            // LEFT: top N categories list
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Theme.spacing.sm

                Repeater {
                    model: Math.min(4, root.categories.length)

                    delegate: RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.xs

                        ColumnLayout {
                            Layout.fillWidth: true

                            Text {
                                text: root.categories[index].name
                                font.pixelSize: Theme.text.sSize
                                color: Theme.color.textPrimary
                            }

                            Text {
                                text: "$ " +
                                      Number(root.categories[index].value)
                                      .toLocaleString(Qt.locale(), 'f', 2) +
                                      " · Last Week"
                                font.pixelSize: Theme.text.xsSize
                                color: Theme.color.textMuted
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }


        }
    }
}
