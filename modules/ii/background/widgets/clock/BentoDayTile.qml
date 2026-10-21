import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

/*
 * The day in four steps, sunrise, midday, sunset and night,
 * joined by a track that fills as the day goes.
 */
BentoTile {
    id: root
    required property var sunrise // Date
    required property var sunset // Date
    required property date now

    readonly property var midday: new Date((root.sunrise.getTime() + root.sunset.getTime()) / 2)
    readonly property bool beforeSunrise: root.now < root.sunrise
    readonly property bool afterSunset: root.now >= root.sunset
    readonly property bool night: root.beforeSunrise || root.afterSunset
    readonly property var nextSunrise: root.afterSunset ? new Date(root.sunrise.getTime() + 24 * 3600 * 1000) : root.sunrise

    readonly property string stageName: {
        if (root.night) return Translation.tr("Night");
        if (root.now < root.midday) return Translation.tr("Morning");
        return Translation.tr("Afternoon");
    }
    readonly property string countdown: root.night
        ? Translation.tr("Sunrise in %1").arg(root.formatDuration(root.nextSunrise - root.now))
        : Translation.tr("Sunset in %1").arg(root.formatDuration(root.sunset - root.now))

    function formatDuration(ms) {
        const minutes = Math.max(0, Math.round(ms / 60000));
        const hours = Math.floor(minutes / 60);
        return hours > 0 ? `${hours} h ${String(minutes % 60).padStart(2, "0")}` : `${minutes} min`;
    }
    function formatTime(d) {
        return Qt.locale().toString(d, Config.options?.time.format ?? "hh:mm");
    }
    function fraction(from, to) {
        return Math.max(0, Math.min(1, (root.now - from) / (to - from)));
    }

    readonly property var steps: [
        { icon: "wb_twilight", label: root.formatTime(root.sunrise), reached: !root.beforeSunrise, current: !root.night && root.now < root.midday },
        { icon: "clear_day", label: root.formatTime(root.midday), reached: !root.night && root.now >= root.midday, current: !root.night && root.now >= root.midday },
        { icon: "nights_stay", label: root.formatTime(root.sunset), reached: root.afterSunset, current: false },
        { icon: "bedtime", label: Translation.tr("Night"), reached: root.night, current: root.night }
    ]
    // How full each track between two steps is
    readonly property var tracks: [
        root.beforeSunrise ? 0 : root.fraction(root.sunrise, root.midday),
        root.beforeSunrise ? 0 : root.fraction(root.midday, root.sunset),
        root.afterSunset ? 1 : 0
    ]

    implicitHeight: content.implicitHeight + 24

    ColumnLayout {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 16
            rightMargin: 16
        }
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            StyledText {
                Layout.fillWidth: true
                text: root.stageName
                color: Appearance.colors.colOnSurface
                font {
                    pixelSize: Appearance.font.pixelSize.normal
                    weight: 600
                }
            }
            StyledText {
                text: root.countdown
                color: Appearance.colors.colOnSurfaceVariant
                font.pixelSize: Appearance.font.pixelSize.smaller
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: root.steps.length * 2 - 1
                delegate: Loader {
                    id: slot
                    required property int index
                    readonly property bool isStep: index % 2 === 0
                    Layout.fillWidth: !isStep
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: isStep ? 0 : 16
                    sourceComponent: isStep ? stepComponent : trackComponent

                    Component {
                        id: stepComponent
                        ColumnLayout {
                            readonly property var step: root.steps[slot.index / 2]
                            spacing: 4
                            MaterialShapeWrappedMaterialSymbol {
                                Layout.alignment: Qt.AlignHCenter
                                shape: parent.step.current ? MaterialShape.Shape.Cookie9Sided : MaterialShape.Shape.Circle
                                color: parent.step.reached ? Appearance.colors.colPrimary : Appearance.colors.colSecondaryContainer
                                colSymbol: parent.step.reached ? Appearance.colors.colOnPrimary : Appearance.colors.colOnSecondaryContainer
                                text: parent.step.icon
                                fill: parent.step.reached ? 1 : 0
                                iconSize: 18
                                padding: 8
                                implicitWidth: 36
                                implicitHeight: 36
                            }
                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: parent.step.label
                                color: parent.step.current ? Appearance.colors.colOnSurface : Appearance.colors.colOnSurfaceVariant
                                font {
                                    pixelSize: Appearance.font.pixelSize.smallest
                                    weight: parent.step.current ? 600 : 400
                                }
                            }
                        }
                    }

                    Component {
                        id: trackComponent
                        Rectangle {
                            readonly property real progress: root.tracks[(slot.index - 1) / 2]
                            implicitHeight: 4
                            radius: height / 2
                            color: Appearance.colors.colSecondaryContainer
                            Rectangle {
                                width: parent.width * parent.progress
                                height: parent.height
                                radius: height / 2
                                color: Appearance.colors.colPrimary
                                Behavior on width {
                                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
