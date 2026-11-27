import QtQuick
import QtQuick.Shapes

// The clock from conky's clock.lua, redrawn in QML with the same numbers.
// Everything is laid out in clock.lua's 1920x1080 design space; one instance
// shows one block ("date", "clock" or "ring"), cropped to the area that
// starts at (originX, originY) in design space and scaled by sceneScale.
// Pure QtQuick (no Plasma imports), so it can also be rendered off-screen.
Item {
    id: scene

    property string block: "date"
    property real originX: 0
    property real originY: 0
    property real sceneScale: 1
    property date now: new Date()

    // stats, already formatted ("—" when unknown)
    property bool showStats: true
    property string cpuText: "—"
    property string tempText: "—"
    property int tempLevel: 0          // 0 normal, 1 warm (>= 75), 2 hot (>= 90)
    property string ramText: "—"
    property string swapText: "—"
    property string gpuLabel: "GPU"
    property string gpuText: "—"
    property string batText: "—"

    clip: true

    // ---- settings (clock.lua)
    readonly property color white: Qt.rgba(0.90, 0.95, 1.00, 1)
    readonly property color blue:  Qt.rgba(0.60, 0.80, 0.98, 1)
    readonly property color warm:  Qt.rgba(1.00, 0.74, 0.50, 1)
    readonly property color hot:   Qt.rgba(1.00, 0.50, 0.55, 1)
    readonly property real topLine: 64      // shared top line (cap tops)
    readonly property real bottomLine: 470  // shared bottom line (year / AM-PM baselines)
    readonly property real leftX: 84
    readonly property real rightEdge: 1840
    readonly property real ruleLen: 120

    // ---- time
    readonly property var en: Qt.locale("en_US")
    readonly property string dayText: String(now.getDate())
    readonly property string monthText: now.toLocaleDateString(en, "MMMM")
    readonly property string weekdayText: now.toLocaleDateString(en, "dddd").toUpperCase()
    readonly property string yearText: String(now.getFullYear())
    readonly property string hourText: Qt.formatTime(now, "hh AP").split(" ")[0]   // 12-hour, zero padded
    readonly property string minuteText: Qt.formatTime(now, "mm")
    readonly property string ampmText: now.getHours() < 12 ? "AM" : "PM"

    function withAlpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }

    // ---------------------------------------------------------------- pieces
    // Text placed by its baseline (cairo draws at the baseline too)
    component BaseText: Text {
        property real baseY: 0
        y: baseY - baselineOffset
        textFormat: Text.PlainText
        renderType: Text.QtRendering
    }

    // Letter-spaced text right-aligned to edgeX (the trailing spacing does not count)
    component RightText: BaseText {
        property real edgeX: 0
        readonly property real trackedWidth: contentWidth - font.letterSpacing
        x: edgeX - trackedWidth
    }

    // Outlined translucent numerals in Poppins ExtraLight: ink top at inkTop,
    // ink edge at edgeX, digit height targetH, shrunk to fit maxW
    component Numeral: Item {
        id: num
        property string text
        property real edgeX
        property bool alignRight: false
        property real inkTop
        property real targetH
        property real maxW
        property color fillColor
        property color strokeColor
        property real lineWidth: 2.5

        readonly property real baseSize: 100 * targetH / Math.max(1, ref.tightBoundingRect.height)
        readonly property real fontSize: probe.tightBoundingRect.width > maxW
            ? baseSize * maxW / probe.tightBoundingRect.width : baseSize
        readonly property real inkBottom: inkTop + fin.tightBoundingRect.height

        TextMetrics { id: ref;   font.family: "Poppins"; font.weight: Font.ExtraLight; font.pixelSize: 100; text: "0" }
        TextMetrics { id: probe; font.family: "Poppins"; font.weight: Font.ExtraLight; font.pixelSize: num.baseSize; text: num.text }
        TextMetrics { id: fin;   font.family: "Poppins"; font.weight: Font.ExtraLight; font.pixelSize: num.fontSize; text: num.text }

        Shape {
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                fillColor: num.fillColor
                strokeColor: num.strokeColor
                strokeWidth: num.lineWidth
                PathText {
                    // PathText puts the top of the glyph ink at y and the pen origin at x
                    x: num.alignRight ? num.edgeX - (fin.tightBoundingRect.x + fin.tightBoundingRect.width)
                                      : num.edgeX - fin.tightBoundingRect.x
                    y: num.inkTop
                    font.family: "Poppins"
                    font.weight: Font.ExtraLight
                    font.pixelSize: num.fontSize
                    text: num.text
                }
            }
        }
    }

    // Short 1.5 px rule that fades out (toRight: opaque at x, fading to the right)
    component FadeRule: Rectangle {
        property real centerY
        property bool toRight: true
        property color ruleColor
        y: centerY - height / 2
        width: 120
        height: 1.5
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: Qt.rgba(ruleColor.r, ruleColor.g, ruleColor.b, toRight ? 0.90 : 0) }
            GradientStop { position: 1; color: Qt.rgba(ruleColor.r, ruleColor.g, ruleColor.b, toRight ? 0 : 0.90) }
        }
    }

    // Stat: small tracked label with the value 25 px below
    component Stat: Item {
        property string label
        property string value
        property real baseY
        property color labelColor
        property color valueColor
        BaseText {
            baseY: parent.baseY
            text: parent.label
            color: parent.labelColor
            font.family: "Poppins"; font.weight: Font.Medium; font.pixelSize: 11; font.letterSpacing: 3
        }
        BaseText {
            baseY: parent.baseY + 25
            text: parent.value
            color: parent.valueColor
            font.family: "Poppins"; font.weight: Font.Light; font.pixelSize: 19
        }
    }

    // ---------------------------------------------------------------- design space
    Item {
        id: design
        width: 1920
        height: 1080
        transform: [
            Translate { x: -scene.originX; y: -scene.originY },
            Scale { xScale: scene.sceneScale; yScale: scene.sceneScale }
        ]

        Loader { anchors.fill: parent; active: scene.block === "date";  sourceComponent: dateBlock }
        Loader { anchors.fill: parent; active: scene.block === "clock"; sourceComponent: clockBlock }
        Loader { anchors.fill: parent; active: scene.block === "ring";  sourceComponent: ringBlock }
    }

    // Metrics shared by the date and clock blocks
    TextMetrics { id: zero17; font.family: "Poppins"; font.weight: Font.Light; font.pixelSize: 17; text: "0" }

    // ---------------------------------------------------------------- LEFT: date + stats
    Component {
        id: dateBlock
        Item {
            // weekday: small tracked caps, cap top on the top line
            TextMetrics { id: capT; font.family: "Poppins"; font.weight: Font.Light; font.pixelSize: 19; text: "T" }
            BaseText {
                x: scene.leftX
                baseY: scene.topLine - capT.tightBoundingRect.y
                text: scene.weekdayText
                color: scene.withAlpha(scene.blue, 0.92)
                font.family: "Poppins"; font.weight: Font.Light; font.pixelSize: 19; font.letterSpacing: 9
            }

            // day number
            Numeral {
                id: day
                text: scene.dayText
                edgeX: scene.leftX
                inkTop: scene.topLine + 34
                targetH: 200
                maxW: 330
                fillColor: scene.withAlpha(scene.white, 0.10)
                strokeColor: scene.withAlpha(scene.white, 0.55)
            }

            // month: italic serif below the number, cap height 58, max width 330
            TextMetrics { id: capN; font.family: "Cormorant Garamond"; font.weight: Font.Medium; font.italic: true; font.pixelSize: 100; text: "N" }
            TextMetrics {
                id: monthProbe
                font.family: "Cormorant Garamond"; font.weight: Font.Medium; font.italic: true
                font.pixelSize: 100 * 58 / Math.max(1, capN.tightBoundingRect.height)
                text: scene.monthText
            }
            TextMetrics {
                id: monthFit
                font.family: "Cormorant Garamond"; font.weight: Font.Medium; font.italic: true
                font.pixelSize: monthProbe.tightBoundingRect.width > 330
                    ? monthProbe.font.pixelSize * 330 / monthProbe.tightBoundingRect.width
                    : monthProbe.font.pixelSize
                text: scene.monthText
            }
            BaseText {
                x: scene.leftX - monthFit.tightBoundingRect.x
                baseY: day.inkBottom + 26 + 58
                text: scene.monthText
                color: scene.withAlpha(scene.white, 0.96)
                font: monthFit.font
            }

            // rule + year on the bottom line
            BaseText {
                x: scene.leftX + scene.ruleLen + 18
                baseY: scene.bottomLine
                text: scene.yearText
                color: scene.withAlpha(scene.white, 0.80)
                font.family: "Poppins"; font.weight: Font.Light; font.pixelSize: 17; font.letterSpacing: 8
            }
            FadeRule {
                x: scene.leftX
                centerY: scene.bottomLine + zero17.tightBoundingRect.y / 2
                toRight: true
                ruleColor: scene.blue
            }

            // stats grid: 2 columns x 3 rows
            Item {
                visible: scene.showStats
                readonly property real x1: scene.leftX
                readonly property real x2: scene.leftX + 170
                readonly property real y0: scene.bottomLine + 70
                readonly property real dy: 64
                Stat { x: parent.x1; baseY: parent.y0;                label: "CPU";  value: scene.cpuText;  labelColor: scene.withAlpha(scene.blue, 0.70); valueColor: scene.withAlpha(scene.white, 0.94) }
                Stat { x: parent.x2; baseY: parent.y0;                label: "TEMP"; value: scene.tempText; labelColor: scene.withAlpha(scene.blue, 0.70)
                       valueColor: scene.withAlpha(scene.tempLevel === 2 ? scene.hot : scene.tempLevel === 1 ? scene.warm : scene.white, 0.94) }
                Stat { x: parent.x1; baseY: parent.y0 + parent.dy;     label: "RAM";  value: scene.ramText;  labelColor: scene.withAlpha(scene.blue, 0.70); valueColor: scene.withAlpha(scene.white, 0.94) }
                Stat { x: parent.x2; baseY: parent.y0 + parent.dy;     label: "SWAP"; value: scene.swapText; labelColor: scene.withAlpha(scene.blue, 0.70); valueColor: scene.withAlpha(scene.white, 0.94) }
                Stat { x: parent.x1; baseY: parent.y0 + 2 * parent.dy; label: scene.gpuLabel; value: scene.gpuText; labelColor: scene.withAlpha(scene.blue, 0.70); valueColor: scene.withAlpha(scene.white, 0.94) }
                Stat { x: parent.x2; baseY: parent.y0 + 2 * parent.dy; label: "BAT";  value: scene.batText;  labelColor: scene.withAlpha(scene.blue, 0.70); valueColor: scene.withAlpha(scene.white, 0.94) }
            }
        }
    }

    // ---------------------------------------------------------------- RIGHT: clock
    Component {
        id: clockBlock
        Item {
            Numeral {
                text: scene.hourText
                alignRight: true
                edgeX: scene.rightEdge
                inkTop: scene.topLine
                targetH: 168
                maxW: 250
                fillColor: scene.withAlpha(scene.white, 0.10)
                strokeColor: scene.withAlpha(scene.white, 0.55)
            }
            Numeral {
                text: scene.minuteText
                alignRight: true
                edgeX: scene.rightEdge
                inkTop: scene.topLine + 168 + 26
                targetH: 168
                maxW: 250
                fillColor: scene.withAlpha(scene.blue, 0.22)
                strokeColor: scene.withAlpha(scene.blue, 0.80)
            }
            RightText {
                id: ampm
                edgeX: scene.rightEdge
                baseY: scene.bottomLine
                text: scene.ampmText
                color: scene.withAlpha(scene.white, 0.80)
                font.family: "Poppins"; font.weight: Font.Light; font.pixelSize: 17; font.letterSpacing: 8
            }
            FadeRule {
                x: scene.rightEdge - ampm.trackedWidth - 18 - width
                centerY: scene.bottomLine + zero17.tightBoundingRect.y / 2
                toRight: false
                ruleColor: scene.blue
            }
        }
    }

    // ---------------------------------------------------------------- ring around the girl
    // Only this instance's area is painted (the full ring is far bigger).
    Component {
        id: ringBlock
        Canvas {
            x: scene.originX
            y: scene.originY
            width: scene.width / scene.sceneScale
            height: scene.height / scene.sceneScale
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.translate(-x, -y)
                const cx = 1010, cy = 450, r = 600, soft = 14, baseAlpha = 0.40
                const arcs = [[179, 203], [298, 322]]   // both 24 deg long
                const mod = (v, m) => ((v % m) + m) % m             // floored modulo, like Lua's %
                const circDist = (a, b) => Math.abs(mod(a - b + 180, 360) - 180)
                ctx.lineWidth = 1.5
                ctx.lineCap = "butt"
                for (let deg = 0; deg < 360; deg++) {
                    const d = mod(deg + 0.5, 360)
                    let best = 0
                    for (const [from, to] of arcs) {
                        let v = (d >= from && d <= to) ? 1
                            : Math.max(0, 1 - Math.min(circDist(d, from), circDist(d, to)) / soft)
                        v = v * v * (3 - 2 * v)
                        if (v > best) best = v
                    }
                    const a = baseAlpha * best
                    if (a > 0.004) {
                        ctx.strokeStyle = Qt.rgba(0.90, 0.95, 1.00, a)
                        ctx.beginPath()
                        ctx.arc(cx, cy, r, deg * Math.PI / 180, (deg + 1.2) * Math.PI / 180, false)
                        ctx.stroke()
                    }
                }
            }
        }
    }
}
