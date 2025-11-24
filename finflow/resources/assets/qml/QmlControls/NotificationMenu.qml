// QmlControls/NotificationMenu.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QmlControls 1.0    // Theme

Popup {
    id: root
    modal: false
    focus: true
    padding: 0

    // FontAwesome family (override from outside if needed)
    property string faFamily: Theme.text.iconFontFamily

    // Array of notifications:
    // [ { title: "Payment received", message: "From Alex", timestamp: "2m ago", read: false }, ... ]
    property var notifications: []

    // derived unread count
    readonly property int unreadCount: {
        var c = 0
        for (var i = 0; i < notifications.length; ++i)
            if (!notifications[i].read) c++
        return c
    }

    // selection / hover
    property int hoveredIndex: -1

    signal notificationClicked(int index)

    // layout sizing
    property int rowHeight: 60 + Theme.spacing.md
    property int headerHeight: 40
    property int maxVisibleRows: 4

    implicitWidth: 320
    implicitHeight: {
        var rows = Math.min(notifications.length, maxVisibleRows)
        var listHeight = rows * rowHeight
        var margins = Theme.spacing.lg * 2
        // header + list + bottom margin (tiny)
        return headerHeight + listHeight + margins
    }

    background: Rectangle {
        radius: Theme.radius.lg
        color: Theme.color.cardBg
        border.color: Theme.color.textMuted
        border.width: 1
    }

    Item {
        id: contentWrapper
        anchors.fill: parent
        scale: 1.0

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacing.lg
            spacing: Theme.spacing.sm

            // Header row
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: headerHeight

                Text {
                    text: "Notifications"
                    color: Theme.color.textPrimary
                    font.pixelSize: Theme.text.baseSize
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                // unread badge in header too (optional)
                Rectangle {
                    visible: root.unreadCount > 0
                    radius: height / 2
                    height: 18
                    width: Math.max(18, contentWidth + 8)
                    color: Theme.color.accentDanger

                    property int contentWidth: badgeLabel.paintedWidth

                    Text {
                        id: badgeLabel
                        anchors.centerIn: parent
                        text: root.unreadCount > 9 ? "9+" : root.unreadCount
                        color: Theme.color.textPrimary
                        font.pixelSize: Theme.text.xsSize
                    }
                }
            }

            // Notifications list
            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: {
                    var rows = Math.min(notifications.length, maxVisibleRows)
                    return rows * rowHeight
                }
                clip: true

                ColumnLayout {
                    width: parent.width
                    spacing: Theme.spacing.xs

                    Repeater {
                        model: notifications.length

                        Rectangle {
                            Layout.fillWidth: true
                            height: rowHeight
                            radius: Theme.radius.md

                            property bool isUnread: !notifications[index].read
                            property bool isHovered: index === root.hoveredIndex

                            color: isHovered
                                   ? Theme.color.cardBg
                                   : "transparent"

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true

                                onClicked: {
                                    root.notificationClicked(index)
                                }

                                onEntered: root.hoveredIndex = index
                                onExited: if (root.hoveredIndex === index)
                                              root.hoveredIndex = -1
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.spacing.sm
                                spacing: Theme.spacing.sm

                                // left icon (bell / info)
                                Text {
                                    text: isUnread ? "\uf0f3" : "\uf0f3" // fa-bell for both, could vary
                                    font.family: root.faFamily
                                    font.pixelSize: Theme.text.baseSize
                                    color: isUnread
                                           ? Theme.color.accentInfo
                                           : Theme.color.textSecondary
                                    Layout.alignment: Qt.AlignTop
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: Theme.spacing.xs

                                        Text {
                                            Layout.fillWidth: true
                                            text: notifications[index].title || "Notification"
                                            color: isUnread
                                                   ? Theme.color.textPrimary
                                                   : Theme.color.textSecondary
                                            font.pixelSize: Theme.text.baseSize
                                            elide: Text.ElideRight
                                        }

                                        // unread dot
                                        Rectangle {
                                            visible: isUnread
                                            width: 6
                                            height: 6
                                            radius: 3
                                            color: Theme.color.accentDanger
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: notifications[index].message || ""
                                        color: Theme.color.textMuted
                                        font.pixelSize: Theme.text.sSize
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: notifications[index].timestamp || ""
                                        color: Theme.color.textMuted
                                        font.pixelSize: Theme.text.xsSize
                                    }
                                }
                            }
                        }
                    }

                    // empty state
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: notifications.length === 0 ? 60 : 0
                        visible: notifications.length === 0

                        Column {
                            anchors.centerIn: parent
                            spacing: Theme.spacing.xs

                            Text {
                                text: "No notifications"
                                color: Theme.color.textSecondary
                                font.pixelSize: Theme.text.baseSize
                            }
                        }
                    }
                }
            }
        }
    }

    // fade + scale animation
    enter: Transition {
        NumberAnimation {
            target: root
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 120
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: contentWrapper
            property: "scale"
            from: 0.9
            to: 1.0
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    exit: Transition {
        NumberAnimation {
            target: root
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 100
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: contentWrapper
            property: "scale"
            from: 1.0
            to: 0.9
            duration: 100
            easing.type: Easing.InCubic
        }
    }
}
