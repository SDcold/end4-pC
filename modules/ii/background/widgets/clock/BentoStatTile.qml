import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

// A small bento card: an icon in a cookie, a value and what it is
BentoTile {
    id: root
    property string icon
    property string value
    property string label
    property color colAccent: Appearance.colors.colSecondaryContainer
    property color colOnAccent: Appearance.colors.colOnSecondaryContainer
    implicitHeight: 64

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 8
            rightMargin: 10
        }
        spacing: 8
        MaterialShapeWrappedMaterialSymbol {
            shape: MaterialShape.Shape.Cookie7Sided
            color: root.colAccent
            colSymbol: root.colOnAccent
            text: root.icon
            fill: 1
            iconSize: 16
            padding: 7
            implicitWidth: 34
            implicitHeight: 34
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: -2
            StyledText {
                Layout.fillWidth: true
                text: root.value
                elide: Text.ElideRight
                color: Appearance.colors.colOnSurface
                font {
                    pixelSize: Appearance.font.pixelSize.normal
                    weight: 600
                }
            }
            StyledText {
                Layout.fillWidth: true
                text: root.label
                elide: Text.ElideRight
                color: Appearance.colors.colOnSurfaceVariant
                font.pixelSize: Appearance.font.pixelSize.smaller
            }
        }
    }
}
