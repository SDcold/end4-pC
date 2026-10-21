import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.services
import qs.modules.common
import qs.modules.common.widgets

// The playing track, its progress and a play/pause button
BentoTile {
    id: root
    required property MprisPlayer player
    readonly property bool playing: root.player?.isPlaying ?? false
    readonly property bool hasProgress: (root.player?.lengthSupported ?? false) && (root.player?.length ?? 0) > 0

    // Position read every frame while playing, so the bar glides instead of jumping each second
    property real position: 0
    function readPosition() {
        root.position = root.player?.position ?? 0;
    }
    onPlayerChanged: root.readPosition()
    onPlayingChanged: root.readPosition()
    FrameAnimation {
        running: root.playing && root.visible && root.hasProgress
        onTriggered: root.readPosition()
    }
    Connections {
        target: root.player
        function onPostTrackChanged() { root.readPosition(); }
        function onPositionChanged() { if (!root.playing) root.readPosition(); }
    }

    function formatTime(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`;
    }

    implicitHeight: content.implicitHeight + 24
    color: Appearance.colors.colSecondaryContainer

    ColumnLayout {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 10
            rightMargin: 12
        }
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            MaterialShapeWrappedMaterialSymbol {
                shape: MaterialShape.Shape.Cookie9Sided
                color: Appearance.colors.colSecondary
                colSymbol: Appearance.colors.colOnSecondary
                text: "music_note"
                fill: 1
                iconSize: 18
                padding: 8
                implicitWidth: 38
                implicitHeight: 38
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: -2
                StyledText {
                    Layout.fillWidth: true
                    text: root.player?.trackTitle ?? ""
                    elide: Text.ElideRight
                    color: Appearance.colors.colOnSecondaryContainer
                    font {
                        pixelSize: Appearance.font.pixelSize.normal
                        weight: 600
                    }
                }
                StyledText {
                    Layout.fillWidth: true
                    visible: text !== ""
                    text: root.player?.trackArtist ?? ""
                    elide: Text.ElideRight
                    color: Appearance.colors.colOnSecondaryContainer
                    opacity: 0.8
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }
            RippleButton {
                implicitWidth: 40
                implicitHeight: 40
                buttonRadius: Appearance.rounding.full
                colBackground: Appearance.colors.colSecondary
                colBackgroundHover: Appearance.colors.colSecondaryHover
                colRipple: Appearance.colors.colSecondaryActive
                onClicked: MprisController.togglePlaying()
                MaterialSymbol {
                    anchors.centerIn: parent
                    text: root.playing ? "pause" : "play_arrow"
                    fill: 1
                    iconSize: 22
                    color: Appearance.colors.colOnSecondary
                }
            }
        }

        RowLayout {
            visible: root.hasProgress
            Layout.fillWidth: true
            Layout.leftMargin: 4
            spacing: 10
            StyledText {
                text: root.formatTime(root.position)
                color: Appearance.colors.colOnSecondaryContainer
                font {
                    pixelSize: Appearance.font.pixelSize.smallest
                    features: { "tnum": 1 }
                }
            }
            StyledProgressBar {
                Layout.fillWidth: true
                value: root.hasProgress ? Math.min(1, root.position / root.player.length) : 0
                animateValue: false
                // Waves while playing, flat when paused
                wavy: root.playing
                animateWave: root.playing && root.visible
                highlightColor: Appearance.colors.colOnSecondaryContainer
                trackColor: Appearance.colors.colSecondaryContainerActive
            }
            StyledText {
                text: root.formatTime(root.player?.length ?? 0)
                color: Appearance.colors.colOnSecondaryContainer
                font {
                    pixelSize: Appearance.font.pixelSize.smallest
                    features: { "tnum": 1 }
                }
            }
        }
    }
}
