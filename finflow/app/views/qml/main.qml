// main.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QmlControls 1.0

ApplicationWindow {
    id: window
    width: 1280
    height: 768
    visible: true
    flags: Qt.FramelessWindowHint | Qt.Window

    color: Theme.color.windowBg
    title: "FinFlow"

    property var theme: Theme

    FontLoader {
        id: faSolid
        source: "fonts/fa-7-solid-900.otf"   
    }

    FontLoader { 
        id: inter; 
        source: "fonts/Inter-Regular.otf" 
    }

    FontLoader {    
        id: interBold; 
        source: "fonts/Inter-Black.otf" 
    }
    
    
        // Example users list
    property var userList: [
        { "name": "Alex Morgan", "email": "alex@finflow.com", "role": "Admin" },
        { "name": "Priya Gupta", "email": "priya@finflow.com", "role": "Editor" },
        { "name": "John Carter", "email": "john@finflow.com", "role": "Viewer" },
        { "name": "Abe Carter", "email": "abe@finflow.com", "role": "Viewer" },
        { "name": "Carter", "email": "carter@finflow.com", "role": "Viewer" }
    ]

    // Current logged-in index
    property int currentUserIndex: 0

    NotificationMenu {
        id: notificationMenu
        faFamily: faSolid.name

        notifications: [
            { "title": "Payment received", "message": "From Alex", "timestamp": "2 min ago", "read": false },
            { "title": "Budget reached",   "message": "You hit 80% of Groceries", "timestamp": "1 h ago", "read": false },
            { "title": "Reminder",         "message": "Pay credit card bill", "timestamp": "Yesterday", "read": true }
        ]

        onNotificationClicked: function(index) {
            console.log("Notification clicked:", notifications[index].title)
            // Example: mark as read
            notifications[index].read = true
            // force model change if needed
            notifications = notifications
        }
    }

    // UserMenu popup
    UserMenu {
        id: userMenu
        faFamily: faSolid.name
        users: window.userList
        currentIndex: window.currentUserIndex

        onUserSelected: function(index) {
            window.currentUserIndex = index
            console.log("Switched to user:", users[index].name)
        }

        onLogoutRequested: {
            console.log("Logout requested")
        }

        onManageAccountRequested: {
            console.log("Manage account requested")
        }
    }
    // --- top bar with window buttons ---
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TitleBar {
            id: titleBar
            Layout.fillWidth: true
            title: "FinFlow"

            iconSource: "qrc:/icons/app.png"
            targetWindow: window

            // unread notifications
            notificationCount: notificationMenu.unreadCount

            currentUserName: userList.length > 0
                             ? userList[currentUserIndex].name
                             : "User"

            onNotificationClicked: function(gx, gy, gw, gh) {
                notificationMenu.x = gx + gw - notificationMenu.implicitWidth
                notificationMenu.y = gy + gh + 6
                notificationMenu.open()
            }

            onProfileClicked: function(gx, gy, gw, gh) {
                // Position popup near profile button in global coords
                userMenu.x = gx + gw - userMenu.implicitWidth
                userMenu.y = gy + gh + 6
                userMenu.open()
            }
        }

        // --- main content: sidebar + pages ---
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 18

                // sidebar
                Rectangle {
                    id: sidebar
                    Layout.preferredWidth: 90
                    Layout.fillHeight: true
                    radius: 18
                    color: theme.color.sidebarBg

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 30

                        Rectangle {
                            Layout.fillWidth: true
                            height: 48
                            radius: 16
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: theme.color.accentSecondary }
                                GradientStop { position: 1.0; color: theme.color.accentPrimary }
                            }
                            Text {
                                anchors.centerIn: parent
                                text: "A"
                                color: "white"
                                font.pixelSize: 24
                                font.bold: true
                            }
                        }

                        Item { Layout.fillHeight: true } // spacer top

                        ColumnLayout {
                            id: navColumn
                            spacing: 12

                            Repeater {
                                model: [
                                    { label: "Overview",     icon: "\uf0e4" }, // fa-tachometer-alt
                                    { label: "Transactions", icon: "\uf0ec" }, // fa-exchange-alt
                                    { label: "Accounts",     icon: "\uf555" }, // fa-wallet
                                    { label: "Budget",       icon: "\uf200" }, // fa-chart-pie
                                    { label: "Goals",        icon: "\uf140" }  // fa-bullseye
                                ]

                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    height: 60
                                    radius: 16
                                    color: index === stack.currentIndex ? theme.color.accentPrimary : "transparent"

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: stack.currentIndex = index
                                        onEntered: if (index !== stack.currentIndex) parent.color = theme.color.accentPrimary
                                        onExited: if (index !== stack.currentIndex) parent.color = "transparent"
                                    }

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 4

                                        Text {
                                            text: modelData.icon
                                            font.family: faSolid.name
                                            font.pixelSize: theme.text.xlSize
                                            color: index === stack.currentIndex ? "white" : theme.color.textSecondary
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        Text {
                                            text: modelData.label
                                            font.pixelSize: theme.text.sSize
                                            color: index === stack.currentIndex ? "white" : theme.color.textSecondary
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true } // spacer bottom

                        // settings
                        Rectangle {
                            Layout.fillWidth: true
                            height: 50
                            radius: 16
                            color: stack.currentIndex === 5 ? theme.color.accentPrimary : "transparent"

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: stack.currentIndex = 5
                                onEntered: if (stack.currentIndex !== 5) parent.color = theme.color.accentPrimary
                                onExited: if (stack.currentIndex !== 5) parent.color = "transparent"
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: "\uf013"   // fa-cog
                                    font.family: faSolid.name
                                    font.pixelSize: theme.text.sSize
                                    color: stack.currentIndex === 5 ? "white" : theme.color.textSecondary
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                Text {
                                    text: "Settings"
                                    font.pixelSize: theme.text.sSize
                                    color: stack.currentIndex === 5 ? "white" : theme.color.textSecondary
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }
                }

                // main stacked pages container
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 24
                    color: theme.color.mainBg

                    StackLayout {
                        id: stack
                        anchors.fill: parent
                        anchors.margins: 18
                        currentIndex: 0

                        // Overview page
                        OverviewPage {
                            id: overviewPage
                            iconFontFamily: faSolid.name
                        }

                        // Transactions page
                        // PlaceholderPage {
                        //     title: "TRANSACTIONS"
                        //     text: "Transactions page content goes here"
                        // }

                        // PlaceholderPage { title: "ACCOUNTS";       text: "Accounts page content goes here" }
                        // PlaceholderPage { title: "BUDGET";         text: "Budget page content goes here" }
                        // PlaceholderPage { title: "GOALS";          text: "Goals page content goes here" }
                        // PlaceholderPage { title: "SETTINGS";       text: "Settings page content goes here" }
                    }
                }
            }
        }
    }
}
