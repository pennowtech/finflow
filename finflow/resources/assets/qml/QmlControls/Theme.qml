// Theme.qml
pragma Singleton
import QtQuick 2.15

QtObject {
    id: root

    // -----------------------------
    // MODE (reactive)
    // -----------------------------
    // "dark" or "light"
    property string mode: "dark"

    function toggleMode() {
        mode = (mode === "dark" ? "light" : "dark")
    }

    // 🎨 Colors
    readonly property QtObject _darkPalette: QtObject {
        readonly property color windowBg:        "#262b63"
        readonly property color mainBg:          "#0e1131"
        readonly property color sidebarBg:       "#111436"
        readonly property color cardBg:          "#15183f"

        readonly property color textPrimary:     "#ffffff"
        readonly property color textSecondary:   "#8f97c5"
        readonly property color textMuted:       "#7078b3"

        readonly property color accentPrimary:   "#655df5"
        readonly property color accentSecondary: "#5b7cfa"
        readonly property color accentSuccess:   "#23d3a3"
        readonly property color accentDanger:    "#ff4d6d"
        readonly property color accentWarning:   "#fbbf24"
        readonly property color accentInfo:      "#3b82f6"
        
        // title bar specific
        readonly property color titleBarBg:          "#262b63"
        readonly property color titleBarButtonHover: "#222755"
        readonly property color titleBarCloseHover:  "#ff5c5c"
        readonly property color titleBarIconNormal:  "#a9b0e0"
        readonly property color titleBarIconClose:   "#ff8b8b"
    }

    readonly property QtObject _lightPalette: QtObject {
        readonly property color windowBg:        "#d1d4e4"
        readonly property color mainBg:          "#ffffff"
        readonly property color sidebarBg:       "#eef0ff"
        readonly property color cardBg:          "#eef0ff"

        readonly property color textPrimary:     "#020617"
        readonly property color textSecondary:   "#444b58"
        readonly property color textMuted:       "#9ca3af"

        readonly property color accentPrimary:   "#898e97"
        readonly property color accentSecondary: "#9ca3af"
        readonly property color accentSuccess:   "#16a34a"
        readonly property color accentDanger:    "#dc2626"
        readonly property color accentWarning:   "#f59e0b"
        readonly property color accentInfo:      "#3b82f6"
        
        // title bar specific
        readonly property color titleBarBg:          "#e5e7ff"
        readonly property color titleBarButtonHover: "#c7d2fe"
        readonly property color titleBarCloseHover:  "#fecaca"
        readonly property color titleBarIconNormal:  "#4b5563"
        readonly property color titleBarIconClose:   "#b91c1c"
    }

    // 🔹 PUBLIC ColorPalette – this is our ColorManager
    //     Usage: Theme.color.card, Theme.color.primary, Theme.color.titleBarBg...
    readonly property var color: (mode === "dark" ? _darkPalette : _lightPalette)

    // 🔤 Text / typography
    readonly property QtObject text: QtObject {
        readonly property int xsSize: 10
        readonly property int sSize: 12
        readonly property int baseSize:  14
        readonly property int nSize:  baseSize
        readonly property int lSize: 18
        readonly property int xlSize: 24
        readonly property int xxlSize:    32

        readonly property string familyPrimary: "Inter"     // or system default
        readonly property string familyNumeric: "Inter"
        readonly property string iconFontFamily: "FontAwesome" 

        // weights
        readonly property int weightRegular: Font.Normal
        readonly property int weightMedium:  Font.Medium
        readonly property int weightSemibold:Font.DemiBold
        readonly property int weightBold:    Font.Bold
    }

    // 📏 Spacing / radii
    readonly property QtObject spacing: QtObject {
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int xl: 24
        readonly property int xxl:32
    }

    readonly property QtObject radius: QtObject {
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 18    // cards
        readonly property int xl: 24    // windows / panels
    }

    readonly property QtObject elevation: QtObject {
        // You can map these to shadows, blurs, etc.
        readonly property real level0: 0.0
        readonly property real level1: 0.15
        readonly property real level2: 0.25
        readonly property real level3: 0.35
    }
}
