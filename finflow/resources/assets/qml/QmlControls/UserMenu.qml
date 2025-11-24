// FinFlow/UserMenu.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QmlControls 1.0    // Theme singleton

Popup {
    id: root
    modal: false
    focus: true
    padding: 0

    // FontAwesome family for icons (set from outside)
    property string faFamily: ""

    // Array of user objects: [ { name, email, role }, ... ]
    property var users: []
    property int currentIndex: 0

    signal userSelected(int index)
    signal logoutRequested()
    signal manageAccountRequested()

    // --- Size logic based on content ---
    // Per-row / section heights
    property int userRowHeight: 40  + Theme.spacing.md
    property int headerHeight: 72          // header row area
    property int footerSectionHeight: 36 + 36 + Theme.spacing.lg // manage + logout + spacing
    property int maxVisibleUsers: 3        // how many rows before scrolling

    // Total height based on number of users
    implicitWidth: 260
    implicitHeight: {
        var visibleUsers = Math.min(users.length, maxVisibleUsers)
        var listHeight = visibleUsers * userRowHeight
        var margins = Theme.spacing.lg * 2     // top + bottom margins of ColumnLayout
        return headerHeight + listHeight + footerSectionHeight + margins
    }

    // Background using Theme
    background: Rectangle {
        radius: Theme.radius.lg
        color: Theme.color.cardBg
        border.color: Theme.color.textMuted
        border.width: 1
    }

    // Wrap all content so we can animate its scale
    Item {
        id: contentWrapper
        anchors.fill: parent
        scale: 1.0    // for animations

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacing.lg
            spacing: Theme.spacing.sm

            // Header: Current user
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.md

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: Theme.color.accentWarning
                    border.color: Theme.color.accentPrimary

                    Text {
                        anchors.centerIn: parent
                        text: (users.length > 0 && users[currentIndex].name ?
                               users[currentIndex].name.charAt(0).toUpperCase() : "U")
                        color: Theme.color.mainBg
                        font.pixelSize: 16
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.xs

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacing.xxl

                        Text {
                            id: userName
                            text: users.length > 0 ? users[currentIndex].name : "Current User"
                            color: Theme.color.textPrimary
                            font.pixelSize: Theme.text.baseSize
                            elide: Text.ElideRight
                        }


                        // Role / badge for current user
                        Rectangle {
                            visible: users.length > 0 && users[currentIndex].role !== undefined
                            radius: height / 2     // pill
                            color: Theme.color.sidebarBg
                            height: visible ? 18 : 0

                            Layout.alignment: Qt.AlignHCenter

                            Text {
                                anchors.centerIn: parent
                                text: users.length > 0 && users[currentIndex].role !== undefined
                                    ? users[currentIndex].role : ""
                                color: Theme.color.textMuted
                                font.pixelSize: Theme.text.xsSize
                            }
                        }
                    }

                    Text {
                        text: users.length > 0 ? users[currentIndex].email : ""
                        color: Theme.color.textMuted
                        font.pixelSize: Theme.text.sSize
                        elide: Text.ElideRight
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.color.textMuted
                opacity: 0.4
            }

            // User list
            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: {
                    var visibleUsers = Math.min(users.length, maxVisibleUsers)
                    return visibleUsers * userRowHeight
                }
                clip: true

                ColumnLayout {
                    id: listColumn
                    width: parent.width - 12
                    spacing: 4

                    Repeater {
                        model: users.length

                        Rectangle {
                            Layout.fillWidth: true
                            height: 48
                            radius: Theme.radius.md
                            color: index === root.currentIndex
                                   ? Theme.color.sidebarBg
                                   : "transparent"

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    root.currentIndex = index
                                    root.userSelected(index)
                                    root.close()
                                }
                                onEntered: if (index !== root.currentIndex)
                                               parent.color = Theme.color.cardBg
                                onExited: if (index !== root.currentIndex)
                                              parent.color = "transparent"
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: Theme.spacing.sm
                                spacing: Theme.spacing.sm

                                Rectangle {
                                    width: 22
                                    height: 22
                                    radius: 11
                                    color: Theme.color.accentSecondary

                                    Text {
                                        anchors.centerIn: parent
                                        text: (users[index].name ?
                                               users[index].name.charAt(0).toUpperCase() : "?")
                                        color: "white"
                                        font.pixelSize: 12
                                        font.bold: true
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 4

                                        Text {
                                            text: users[index].name
                                            color: Theme.color.textSecondary
                                            font.pixelSize: Theme.text.baseSize
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        // Small role badge per user
                                        Rectangle {
                                            visible: users[index].role !== undefined
                                            radius: height / 2
                                            color: Theme.color.sidebarBg
                                            height: visible ? 16 : 0

                                            Text {
                                                anchors.centerIn: parent
                                                text: users[index].role !== undefined
                                                      ? users[index].role : ""
                                                color: Theme.color.textMuted
                                                font.pixelSize: Theme.text.xsSize
                                            }
                                        }
                                    }

                                    Text {
                                        text: users[index].email
                                        color: Theme.color.textMuted
                                        font.pixelSize: Theme.text.sSize
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // spacer to push footer rows to bottom
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.color.textMuted
                opacity: 0.4
            }

            // Manage account row
            Rectangle {
                Layout.fillWidth: true
                height: 36
                radius: Theme.radius.md
                color: "transparent"

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        root.close()
                        root.manageAccountRequested()
                    }
                    onEntered: parent.color = Theme.color.sidebarBg
                    onExited: parent.color = "transparent"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.sm
                    spacing: Theme.spacing.sm

                    Text {
                        text: "\uf2bb"   // fa-user-cog or similar
                        font.family: root.faFamily
                        font.pixelSize: Theme.text.baseSize
                        color: Theme.color.textSecondary
                    }

                    Text {
                        text: "Manage account"
                        color: Theme.color.textSecondary
                        font.pixelSize: Theme.text.baseSize
                    }
                }
            }
            
            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.color.textMuted
                opacity: 0.4
            }

            // Logout row (bottom)
            Rectangle {
                Layout.fillWidth: true
                height: 36
                radius: Theme.radius.md
                color: "transparent"

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        root.close()
                        root.logoutRequested()
                    }
                    onEntered: parent.color = Theme.color.accentDanger
                    onExited: parent.color = "transparent"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.sm
                    spacing: Theme.spacing.sm

                    Text {
                        text: "\uf2f5"   // fa-sign-out-alt
                        font.family: root.faFamily
                        font.pixelSize: Theme.text.baseSize
                        color: Theme.color.accentDanger
                    }

                    Text {
                        text: "Log out"
                        color: Theme.color.accentDanger
                        font.pixelSize: Theme.text.baseSize
                    }
                }
            }
        }
    }

    // Subtle fade + scale animation (no transform property)
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
