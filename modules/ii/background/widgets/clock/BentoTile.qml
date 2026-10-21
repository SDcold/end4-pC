import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

// A rounded card of the daily clock's bento variant
Item {
    id: root
    property alias color: background.color
    default property alias content: background.data

    Layout.fillWidth: true

    StyledRectangularShadow {
        target: background
        visible: Config.options.background.widgets.shadow
    }

    Rectangle {
        id: background
        anchors.fill: parent
        radius: Appearance.rounding.large
        color: Appearance.colors.colSurfaceContainer
    }
}
