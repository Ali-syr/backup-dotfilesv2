import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.common.widgets.widgetCanvas
import qs.modules.ii.background.widgets

AbstractBackgroundWidget {
    id: root

    property var screen: null
    configEntryName: "clock"

    width: implicitWidth
    height: implicitHeight
    implicitHeight: contentColumn.implicitHeight
    implicitWidth: contentColumn.implicitWidth

    readonly property string clockStyle: GlobalStates.screenLocked ? Config.options.background.widgets.clock.styleLocked : Config.options.background.widgets.clock.style
    readonly property bool forceCenter: (GlobalStates.screenLocked && Config.options.lock.centerClock)
    readonly property bool shouldShow: (!Config.options.background.widgets.clock.showOnlyWhenLocked || GlobalStates.screenLocked)
    readonly property string customClockColorKey: Config.options.background.widgets.clock.color ?? ""
    readonly property color resolvedClockColor: {
        if (customClockColorKey === "") return root.colText;
        const propName = "col" + customClockColorKey.charAt(0).toUpperCase() + customClockColorKey.slice(1);
        return Appearance.colors[propName] ?? root.colText;
    }
    property bool wallpaperSafetyTriggered: false
    needsColText: clockStyle === "digital"

    animateXPos: !root.dragging && !root.groupDragActive && !root.forceCenter && !toCenterAnim.running && !toDesktopAnim.running
    animateYPos: !root.dragging && !root.groupDragActive && !root.forceCenter && !toCenterAnim.running && !toDesktopAnim.running

    readonly property real centerX: (root.screenWidth - root.width) / 2
    readonly property real centerY: (root.screenHeight - root.height) / 2

    readonly property string screenName: root.screen?.name ?? (Quickshell.screens.length > 0 ? Quickshell.screens[0]?.name : "default")
    readonly property var savedDesktopPos: GlobalStates.clockDesktopPositions[screenName]
    readonly property real startX: savedDesktopPos !== undefined ? savedDesktopPos.x : targetX
    readonly property real startY: savedDesktopPos !== undefined ? savedDesktopPos.y : targetY

    property real centerProgress: 0.0

    x: startX + centerProgress * (centerX - startX)
    y: startY + centerProgress * (centerY - startY)
    visibleWhenLocked: true

    NumberAnimation {
        id: toCenterAnim
        target: root
        property: "centerProgress"
        duration: Appearance.animationCurves.expressiveSlowSpatialDuration
        easing.type: Appearance.animation.elementMove.type
        easing.bezierCurve: Appearance.animationCurves.expressiveDefaultSpatial
    }

    NumberAnimation {
        id: toDesktopAnim
        target: root
        property: "centerProgress"
        duration: Appearance.animation.elementMove.duration
        easing.type: Appearance.animation.elementMove.type
        easing.bezierCurve: Appearance.animationCurves.expressiveDefaultSpatial
    }

    function updateDesktopPosition() {
        if (GlobalStates.screenLocked || root.forceCenter) return;
        var next = Object.assign({}, GlobalStates.clockDesktopPositions);
        next[screenName] = { x: root.targetX, y: root.targetY };
        GlobalStates.clockDesktopPositions = next;
    }

    onTargetXChanged: updateDesktopPosition()
    onTargetYChanged: updateDesktopPosition()

    onForceCenterChanged: {
        if (forceCenter) {
            toDesktopAnim.stop();
            toCenterAnim.from = root.centerProgress;
            toCenterAnim.to = 1.0;
            toCenterAnim.restart();
        } else {
            toCenterAnim.stop();
            toDesktopAnim.from = root.centerProgress;
            toDesktopAnim.to = 0.0;
            toDesktopAnim.restart();
        }
    }

    Component.onCompleted: {
        if (!GlobalStates.screenLocked && !root.forceCenter) {
            updateDesktopPosition();
        } else if (root.forceCenter) {
            toDesktopAnim.stop();
            toCenterAnim.from = 0.0;
            toCenterAnim.to = 1.0;
            toCenterAnim.restart();
        }
    }

    function restoreXYBinding() {
        root.x = Qt.binding(() => root.startX + root.centerProgress * (root.centerX - root.startX));
        root.y = Qt.binding(() => root.startY + root.centerProgress * (root.centerY - root.startY));
    }

    property var textHorizontalAlignment: {
        if (!Config.options.background.widgets.clock.digital.adaptiveAlignment || root.centerProgress > 0.5 || Config.options.background.widgets.clock.digital.vertical) 
            return Text.AlignHCenter;
        if (root.x < root.scaledScreenWidth / 3)
            return Text.AlignLeft;
        if (root.x > root.scaledScreenWidth * 2 / 3)
            return Text.AlignRight;
        return Text.AlignHCenter;
    }

    Column {
        id: contentColumn
        anchors.centerIn: parent
        spacing: 10

        FadeLoader {
            id: cookieClockLoader
            anchors.horizontalCenter: parent.horizontalCenter
            shown: root.clockStyle === "cookie" && (root.shouldShow)
            fade: false
            sourceComponent: CookieClock {
                anchors.horizontalCenter: parent.horizontalCenter
                wallpaperItem: root.wallpaperItem
                originX: root.x
                originY: root.y
            }
        }

        FadeLoader {
            id: digitalClockLoader
            anchors.horizontalCenter: parent.horizontalCenter
            shown: root.clockStyle === "digital" && (root.shouldShow)
            fade: false
            sourceComponent: DigitalClock {
                colText: root.resolvedClockColor
                textHorizontalAlignment: root.textHorizontalAlignment
            }
        }

        FadeLoader {
            id: pixelClockLoader
            anchors.horizontalCenter: parent.horizontalCenter
            shown: root.clockStyle === "pixel" && (root.shouldShow)
            fade: false
            sourceComponent: PixelClock {
                wallpaperItem: root.wallpaperItem
                originX: root.x
                originY: root.y
            }
        }

        FadeLoader {
            id: quoteLoader
            anchors.horizontalCenter: parent.horizontalCenter
            shown: Config.options.background.widgets.clock.quote.enable && (root.clockStyle === "pixel" || root.clockStyle === "cookie") && Config.options.background.widgets.clock.quote.text !== "" && root.shouldShow
            sourceComponent: CookieQuote {}
        }

        StatusRow {
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    component StatusRow: Item {
        id: statusText
        implicitHeight: statusTextBg.implicitHeight
        implicitWidth: statusTextBg.implicitWidth
        StyledRectangularShadow {
            target: statusTextBg
            visible: statusTextBg.visible && root.clockStyle === "cookie"
            opacity: statusTextBg.opacity
        }
        Rectangle {
            id: statusTextBg
            anchors.centerIn: parent
            clip: true
            opacity: (safetyStatusText.shown || lockStatusText.shown) ? 1 : 0
            visible: opacity > 0
            implicitHeight: statusTextRow.implicitHeight + 5 * 2
            implicitWidth: statusTextRow.implicitWidth + 5 * 2
            radius: Appearance.rounding.small
            color: ColorUtils.transparentize(Appearance.colors.colSecondaryContainer, root.clockStyle === "cookie" ? 0 : 1)

            Behavior on implicitWidth {
                animation: Appearance.animation.elementResize.numberAnimation.createObject(this)
            }
            Behavior on implicitHeight {
                animation: Appearance.animation.elementResize.numberAnimation.createObject(this)
            }
            Behavior on opacity {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }

            RowLayout {
                id: statusTextRow
                anchors.centerIn: parent
                spacing: 14
                Item {
                    Layout.fillWidth: root.textHorizontalAlignment !== Text.AlignLeft
                    implicitWidth: 1
                }
                ClockStatusText {
                    id: safetyStatusText
                    shown: root.wallpaperSafetyTriggered
                    statusIcon: "hide_image"
                    statusText: Translation.tr("Wallpaper safety enforced")
                }
                ClockStatusText {
                    id: lockStatusText
                    shown: GlobalStates.screenLocked && Config.options.lock.showLockedText
                    statusIcon: "lock"
                    statusText: Translation.tr("Locked")
                }
                Item {
                    Layout.fillWidth: root.textHorizontalAlignment !== Text.AlignRight
                    implicitWidth: 1
                }
            }
        }
    }

    component ClockStatusText: Row {
        id: statusTextRow
        property alias statusIcon: statusIconWidget.text
        property alias statusText: statusTextWidget.text
        property bool shown: true
        property color textColor: root.clockStyle === "cookie" ? Appearance.colors.colOnSecondaryContainer : root.colText
        opacity: shown ? 1 : 0
        visible: opacity > 0
        Behavior on opacity {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }
        spacing: 4
        MaterialSymbol {
            id: statusIconWidget
            anchors.verticalCenter: statusTextRow.verticalCenter
            iconSize: Appearance.font.pixelSize.huge
            color: statusTextRow.textColor
            style: Text.Raised
            styleColor: Appearance.colors.colShadow
        }
        ClockText {
            id: statusTextWidget
            color: statusTextRow.textColor
            horizontalAlignment: root.textHorizontalAlignment
            anchors.verticalCenter: statusTextRow.verticalCenter
            font {
                pixelSize: Appearance.font.pixelSize.large
                weight: Font.Normal
            }
            style: Text.Raised
            styleColor: Appearance.colors.colShadow
        }
    }
}
