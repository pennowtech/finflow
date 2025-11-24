/*
 * TopBar.qml
 * -----------------------------------------------------------------------------
 * A reusable, frameless window title bar with:
 *   - Window dragging
 *   - Minimize / Maximize / Restore / Close buttons
 *   - Font-based icons (e.g. FontAwesome)
 *
 * PARAMETERS (PROPERTIES)
 * -----------------------------------------------------------------------------
 *
 * 1) targetWindow : Window
 *    - REQUIRED
 *    - The id of the Window / ApplicationWindow instance this TopBar controls.
 *    - Used for:
 *        • Moving the window when dragging the left side
 *        • Calling showMinimized(), showMaximized(), showNormal(), close()
 *
 *    Example:
 *        ApplicationWindow {
 *            id: window
 *            ...
 *            TopBar {
 *                targetWindow: window
 *                iconFontFamily: faSolid.name
 *            }
 *        }
 *
 * 2) iconFontFamily : string
 *    - OPTIONAL (but recommended)
 *    - Font family used for the icon characters (minimize, maximize, close).
 *      Typically a loaded icon font, e.g. FontAwesome.
 *    - If left empty, it will fall back to the default application font,
 *      but you will likely see regular characters instead of icons.
 *
 *    Example (with FontAwesome):
 *        FontLoader {
 *            id: faSolid
 *            source: "fonts/fa-solid-900.ttf"
 *        }
 *
 *        TopBar {
 *            targetWindow: window
 *            iconFontFamily: faSolid.name
 *        }
 *
 * 3) Theme pulled from targetWindow.theme if available, otherwise defaultTheme
 *     Expecting something like:
 *      {
 *         titleBarBg: "#262b63",
 *         titleBarButtonHover: "#222755",
 *         titleBarCloseHover: "#ff5c5c",
 *         titleBarIconNormal: "#a9b0e0",
 *         titleBarIconClose: "#ff8b8b"
 *      }
 *
 * SIGNALS
 * -----------------------------------------------------------------------------
 *
 * 1) minimizeRequested()
 *    - Emitted when the minimize button is clicked.
 *    - The component also calls targetWindow.showMinimized() automatically
 *      if targetWindow is set.
 *
 * 2) maximizeRequested()
 *    - Emitted when the maximize / restore button is clicked.
 *    - The component also toggles between targetWindow.showMaximized()
 *      and targetWindow.showNormal() automatically.
 *
 * 3) closeRequested()
 *    - Emitted when the close button is clicked.
 *    - The component also calls targetWindow.close() automatically
 *      if targetWindow is set.
 *
 *    Example usage:
 *        TopBar {
 *            id: titleBar
 *            targetWindow: window
 *            iconFontFamily: faSolid.name
 *
 *            onCloseRequested: {
 *                console.log("Window is closing")
 *            }
 *        }
 *
 *
 * FEATURES / BEHAVIOR
 * -----------------------------------------------------------------------------
 *
 * - Frameless window support:
 *     • Intended to be used with a Window/ApplicationWindow that has
 *       Qt.FramelessWindowHint set in its flags.
 *
 * - Drag-to-move:
 *     • Clicking and dragging on the LEFT area of the bar moves the window.
 *     • Buttons on the RIGHT are not draggable and correctly receive clicks.
 *
 * - Window controls:
 *     • Minimize button:
 *          - Icon: FontAwesome "window-minimize" (U+F2D1) by default.
 *          - Calls showMinimized() on targetWindow.
 *
 *     • Maximize / Restore button:
 *          - Toggles between maximize and normal state.
 *          - Icon switches between:
 *                - window-maximize (U+F2D0) when normal
 *                - window-restore  (U+F2D2) when maximized
 *
 *     • Close button:
 *          - Icon: FontAwesome "times" (U+F00D) by default.
 *          - Calls close() on targetWindow.
 *
 * - Styling:
 *     • Uses subtle rounded backgrounds on hover.
 *     • Colors are tuned for dark UIs (#262b63 / #111436 style),
 *       but can be easily overridden via parent styling / themes.
 *
 *
 * MINIMAL USAGE EXAMPLE
 * -----------------------------------------------------------------------------
 *
 *   // main.qml
 *   import QtQuick 2.15
 *   import QtQuick.Controls 2.15
 *   import QtQuick.Layouts 1.15
 *
 *   ApplicationWindow {
 *       id: window
 *       width: 1280
 *       height: 768
 *       visible: true
 *       flags: Qt.FramelessWindowHint
 *
 *       FontLoader {
 *           id: faSolid
 *           source: "fonts/fa-solid-900.ttf"  // path to FontAwesome TTF
 *       }
 *
 *       ColumnLayout {
 *           anchors.fill: parent
 *           spacing: 0
 *
 *           TopBar {
 *               Layout.fillWidth: true
 *               targetWindow: window
 *               iconFontFamily: faSolid.name
 *           }
 *
 *           // Rest of your app content
 *           Rectangle {
 *               Layout.fillWidth: true
 *               Layout.fillHeight: true
 *               color: "#0e1131"
 *           }
 *       }
 *   }
 *
 * -----------------------------------------------------------------------------
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    // Window this titlebar controls (ApplicationWindow, Window, etc.)
    property Window targetWindow

    property string iconFontFamily: Theme.text.iconFontFamily

    // Height of the bar; width is provided by parent / layout
    implicitHeight: 36
    implicitWidth: buttonsRow.implicitWidth + Theme.spacing.sm

    // Optional signals for external logic
    signal minimizeRequested()
    signal maximizeRequested()
    signal closeRequested()

    RowLayout {
        id: buttonsRow
        anchors.fill: parent
        anchors.margins: 8
        spacing: 0

        // RIGHT: window control buttons
        RowLayout {
            spacing: 4

            // Minimize button
            Rectangle {
                width: Theme.text.xlSize
                height: Theme.text.xlSize
                radius: Theme.radius.md
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "\uf2d1"              // FontAwesome window-minimize
                    font.family: root.iconFontFamily
                    font.pixelSize: Theme.text.sSize
                    color: Theme.color.titleBarIconNormal
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (root.targetWindow) {
                            root.targetWindow.showMinimized()
                        }
                        root.minimizeRequested()
                    }
                    onEntered: parent.color = Theme.color.titleBarButtonHover
                    onExited: parent.color = "transparent"
                }
            }

            // Maximize / restore button
            Rectangle {
                width: Theme.text.xlSize
                height: Theme.text.xlSize
                radius: Theme.radius.md
                color: "transparent"

                Text {
                    id: maxIcon
                    anchors.centerIn: parent
                    text: (root.targetWindow && root.targetWindow.visibility === Window.Maximized)
                          ? "\uf2d2" // window-restore
                          : "\uf2d0" // window-maximize
                    font.family: root.iconFontFamily
                    font.pixelSize: Theme.text.sSize
                    color: Theme.color.titleBarIconNormal
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (!root.targetWindow)
                            return
                        if (root.targetWindow.visibility === Window.Maximized)
                            root.targetWindow.showNormal()
                        else
                            root.targetWindow.showMaximized()
                        root.maximizeRequested()
                    }
                    onEntered: parent.color = Theme.color.titleBarButtonHover
                    onExited: parent.color = "transparent"
                }

                // Keep the icon in sync with window state
                Connections {
                    target: root.targetWindow
                    function onVisibilityChanged() {
                        if (!root.targetWindow)
                            return
                        maxIcon.text = (root.targetWindow.visibility === Window.Maximized)
                                       ? "\uf2d2"
                                       : "\uf2d0"
                    }
                }
            }

            // Close button
            Rectangle {
                width: Theme.text.xlSize
                height: Theme.text.xlSize
                radius: Theme.radius.md
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "\uf00d"              // FontAwesome times (close)
                    font.family: root.iconFontFamily
                    font.pixelSize: Theme.text.sSize
                    color: Theme.color.titleBarIconClose
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        root.closeRequested()
                        if (root.targetWindow)
                            root.targetWindow.close()
                    }
                    onEntered: parent.color = Theme.color.titleBarCloseHover
                    onExited: parent.color = "transparent"
                }
            }
        }
    }
}
