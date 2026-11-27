import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support

// Rainmeter Clock: Plasma desktop widget version of the conky clock.
// Drawing lives in Scene.qml; this file feeds it the time, the stats and the
// per-instance settings (origin, scale, ring) written by rainmeter.nix.
PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    // only the instance whose area contains the stats grid reads the stats
    readonly property bool needsStats: fullRepresentationItem ? fullRepresentationItem.showsDate : false

    // ---- click-through
    // The desktop wraps every widget in an applet container that takes all
    // clicks inside its box (so it can be dragged in Edit Mode). The clock only
    // draws, so disable input on that container: Qt then delivers clicks to
    // whatever is below (desktop icons, the desktop's right-click menu).
    // Side effect: the pieces cannot be dragged/resized in Edit Mode (the
    // layout comes from rainmeter.nix anyway). If a future Plasma names the
    // container differently, nothing is disabled and the clock still works.
    property int clickThroughTries: 0
    Timer {
        id: clickThroughTimer
        interval: 500
        repeat: true
        running: true
        onTriggered: {
            root.clickThroughTries++
            let item = root.parent
            const chain = []
            while (item) {
                const name = String(item)
                chain.push(name.split("(")[0])
                if (/AppletContainer|ItemContainer/.test(name)) {
                    item.enabled = false
                    console.log("rainmeter: click-through enabled on", name.split("(")[0])
                    running = false
                    return
                }
                item = item.parent
            }
            if (root.clickThroughTries >= 20) {     // give up after 10 s
                console.warn("rainmeter: no applet container found, clicks stay on the widget; chain:", chain.join(" > "))
                running = false
            }
        }
    }

    property date now: new Date()
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    // ---- stats (only the "date" block shows them)
    property string cpuText: "—"
    property string tempText: "—"
    property int tempLevel: 0
    property string ramText: "—"
    property string swapText: "—"
    property string gpuLabel: "GPU"
    property string gpuText: "—"
    property string batText: "—"

    property real prevTotal: 0
    property real prevIdle: 0
    property var rc6Prev: ({})
    property var gpuLast: ({})

    // rainmeter-stats prints one snapshot of raw counters as key=value lines
    readonly property string statsCommand: "@STATS@"

    P5Support.DataSource {
        id: statsSource
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            root.parseStats(data["stdout"] || "")
            disconnectSource(sourceName)
        }
    }

    Timer {
        interval: 2000                       // conky's update_interval
        running: root.needsStats
        repeat: true
        triggeredOnStart: true
        onTriggered: statsSource.connectSource(root.statsCommand)
    }

    function parseStats(out) {
        const kv = {}
        for (const line of out.split("\n")) {
            const i = line.indexOf("=")
            if (i > 0) kv[line.slice(0, i)] = line.slice(i + 1)
        }

        // CPU: share of non-idle jiffies since the previous snapshot
        const total = Number(kv.cpu_total), idle = Number(kv.cpu_idle)
        if (prevTotal > 0 && total > prevTotal)
            cpuText = Math.round(100 * (1 - (idle - prevIdle) / (total - prevTotal))) + "%"
        prevTotal = total
        prevIdle = idle

        ramText  = kv.mem  ? kv.mem  + "%" : "—"
        swapText = kv.swap ? kv.swap + "%" : "—"
        batText  = kv.bat  ? kv.bat  + "%" : "—"

        const t = parseInt(kv.temp)
        tempText  = isNaN(t) ? "—" : t + "°C"
        tempLevel = isNaN(t) ? 0 : (t >= 90 ? 2 : t >= 75 ? 1 : 0)

        // GPU: dedicated first (only while awake), integrated as fallback
        const upMs = Number(kv.up) * 1000
        let shown = null
        for (const kind of ["dedicated", "integrated"]) {
            const raw = kv["gpu_" + kind]
            if (!raw) continue
            const [name, method, value, status] = raw.split("|")
            if (kind === "dedicated" && status === "suspended") continue
            let pct = NaN
            if (method === "busy" || method === "freq") {
                pct = parseInt(value)
            } else if (method === "rc6") {
                // busy share = 1 - (idle-residency growth / time passed)
                const rc6 = Number(value), prev = rc6Prev[kind]
                if (prev && upMs > prev.t)
                    pct = Math.max(0, Math.min(100, Math.round(100 * (1 - (rc6 - prev.rc6) / (upMs - prev.t)))))
                rc6Prev[kind] = { rc6: rc6, t: upMs }
                if (isNaN(pct) && gpuLast[kind] !== undefined) pct = gpuLast[kind]
            }
            if (!isNaN(pct)) {
                gpuLast[kind] = pct
                shown = { name: name, pct: pct }
                break
            }
        }
        gpuLabel = shown ? "GPU · " + shown.name : "GPU"
        gpuText  = shown ? shown.pct + "%" : "—"
    }

    fullRepresentation: Scene {
        showRing: Plasmoid.configuration.ring
        originX: Plasmoid.configuration.originX
        originY: Plasmoid.configuration.originY
        sceneScale: Plasmoid.configuration.scale
        now: root.now
        cpuText: root.cpuText
        tempText: root.tempText
        tempLevel: root.tempLevel
        ramText: root.ramText
        swapText: root.swapText
        gpuLabel: root.gpuLabel
        gpuText: root.gpuText
        batText: root.batText
    }
}
