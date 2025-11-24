// QmlControls/TitleBar.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QmlControls 1.0   // Theme

Rectangle {
    id: root
    height: 40
    color: Theme.color.titleBarBg
    clip: true   // <-- ensures children cannot draw outside the title bar

    // Window this titlebar controls (ApplicationWindow, Window, etc.)
    property Window targetWindow

    // App title
    property string title: "FinFlow"

    property int notificationCount: 0

    // Icon provided by caller (e.g. "qrc:/icons/app.png")
    property url iconSource: ""

    // Current user for avatar
    property string currentUserName: "User"

    // Signal to let parent open the UserMenu
    signal profileClicked(real gx, real gy, real gw, real gh)

    // Signal to let parent open the NotificationMenu
    signal notificationClicked(real gx, real gy, real gw, real gh)

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.lg
        anchors.rightMargin: Theme.spacing.lg
        spacing: Theme.spacing.md

        // LEFT: icon + title (drag area)
        Item {
            id: dragArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.fill: parent
                spacing: Theme.spacing.sm

                // App icon (provided by caller)
                Image {
                    id: appIcon
                    source: root.iconSource
                    visible: iconSource !== ""

                    // hard clamp size so it can never be huge
                    Layout.preferredWidth: visible ? 20 : 0
                    Layout.preferredHeight: visible ? 20 : 0
                    width: Layout.preferredWidth
                    height: Layout.preferredHeight
                }

                Text {
                    id: titleText
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                    text: root.title
                    color: Theme.color.titleBarIconNormal
                    font.pixelSize: Theme.text.lSize
                    elide: Text.ElideRight
                }
            }

            // Window dragging (only on left area)
            MouseArea {
                anchors.fill: parent
                hoverEnabled: false

                property point dragStartPos: Qt.point(0, 0)
                property point windowStartPos: Qt.point(0, 0)

                onPressed: function(mouse) {
                    if (mouse.button === Qt.LeftButton && root.targetWindow) {
                        mouse.accepted = true
                        dragStartPos = Qt.point(mouse.x, mouse.y)
                        windowStartPos = Qt.point(root.targetWindow.x, root.targetWindow.y)
                    }
                }

                onPositionChanged: function(mouse) {
                    if ((mouse.buttons & Qt.LeftButton) && root.targetWindow) {
                        var dx = mouse.x - dragStartPos.x
                        var dy = mouse.y - dragStartPos.y
                        root.targetWindow.x = windowStartPos.x + dx
                        root.targetWindow.y = windowStartPos.y + dy
                    }
                }
            }
        }

        // Notification bell (just before user profile button)
        Rectangle {
            id: notificationButton
            width: 28
            height: 28
            radius: 14
            color: "transparent"

            // bell icon
            Text {
                anchors.centerIn: parent
                text: "\uf0f3"                      // fa-bell
                font.family: Theme.text.iconFontFamily
                font.pixelSize: Theme.text.baseSize
                color: Theme.color.titleBarIconNormal
            }

            // badge
            Rectangle {
                visible: root.notificationCount > 0
                width: Math.max(16, badgeText.paintedWidth + 6)
                height: 16
                radius: 8
                color: Theme.color.accentDanger

                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: -4
                anchors.rightMargin: -4

                Text {
                    id: badgeText
                    anchors.centerIn: parent
                    text: root.notificationCount > 9 ? "9+" : root.notificationCount
                    color: Theme.color.textPrimary
                    font.pixelSize: Theme.text.xsSize
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    // delegate to parent; TitleBar itself shouldn't know about the popup
                    var p = notificationButton.mapToItem(null, 0, 0)
                    root.notificationClicked(p.x, p.y, notificationButton.width, notificationButton.height)
                }

                onEntered: parent.color = Theme.color.titleBarButtonHover
                onExited: parent.color = "transparent"
            }
        }


        // RIGHT: user avatar button (just before window buttons)
        Rectangle {
            id: profileButton
            width: 32
            height: 32
            radius: 16
            color: Theme.color.accentPrimary

            Text {
                anchors.centerIn: parent
                text: currentUserName.length > 0
                      ? currentUserName.charAt(0).toUpperCase()
                      : "U"
                color: "white"
                font.pixelSize: Theme.text.baseSize
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // Map profile button's local coords to global
                    var p = profileButton.mapToItem(null, 0, 0)
                    root.profileClicked(p.x, p.y, profileButton.width, profileButton.height)
                }
            }
        }

        // FAR RIGHT: window buttons
        TopBarWinButtons {
            id: topBarWinButtons
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            targetWindow: root.targetWindow

            onCloseRequested: {
                console.log("Window is closing")
            }
        }
    }
}
