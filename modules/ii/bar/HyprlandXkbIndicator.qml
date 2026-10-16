import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.models
import qs.modules.common.widgets
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Loader {
    id: root
    property color contentColor: Appearance.colors.colOnLayer0
    property bool contentColorOverridden: false
    property bool vertical: false
    property color color: Appearance.colors.colOnSurfaceVariant

    readonly property bool isNiri: WM.compositor === "niri"
    readonly property int layoutCount: isNiri ? NiriXkb.layoutNames.length : HyprlandXkb.layoutCodes.length
    readonly property string layoutName: isNiri ? NiriXkb.currentLayoutName : HyprlandXkb.currentLayoutName

    function switchLayout(direction) {
        if (root.isNiri) NiriXkb.switchLayout(direction);
        else HyprlandXkb.switchLayout(direction);
    }

    sourceComponent: Item {
        // Both sizes are always set: a null one collapsed the item to zero, which
        // still let the text draw but left nothing to click
        implicitWidth: rowLayout.implicitWidth + (root.vertical ? 0 : 8)
        implicitHeight: rowLayout.implicitHeight + (root.vertical ? 6 : 0)

        // Sits above whatever holds the indicator (the system icons open the
        // sidebar on press), so a click on the code switches the layout instead.
        // Right click is left to the bar group, which opens its style editor.
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            anchors.margins: -4
            enabled: root.layoutCount > 1
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.switchLayout("next")
            onWheel: wheel => root.switchLayout(wheel.angleDelta.y > 0 ? "prev" : "next")
        }

        StyledToolTip {
            // A MouseArea has containsMouse, not hovered, and StyledToolTip reads an
            // undefined hovered as "always on"
            extraVisibleCondition: mouseArea.containsMouse
            text: root.layoutName
        }

        RowLayout {
            id: rowLayout
            anchors.centerIn: parent
            spacing: 5

            StyledText {
                id: layoutCodeText
                horizontalAlignment: Text.AlignHCenter
                text: WM.compositor === "niri" ? NiriXkb.currentLayoutCode : HyprlandXkb.currentLayoutCode
                font.pixelSize: Appearance.font.pixelSize.small
                color: root.contentColor
                animateChange: true
            }
        }
    }
}