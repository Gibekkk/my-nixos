// SSH Mode panel widget.
// Polls `sshmode status --short` (off | tailscale | public) and opens
// sshmode-gui on click. Both commands come from nixos/modules/sshmode.nix.
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    readonly property string bin: "/run/current-system/sw/bin/"
    readonly property string statusCmd: bin + "sshmode status --short"
    readonly property string guiCmd: bin + "sshmode-gui"

    property string mode: "…"
    property bool guiOpen: false

    readonly property var info: ({
        "off":       { label: "SSH off",   icon: "network-disconnect", color: Kirigami.Theme.disabledTextColor,
                       text: "SSH server is stopped" },
        "tailscale": { label: "SSH ts",    icon: "network-vpn",        color: Kirigami.Theme.positiveTextColor,
                       text: "Reachable only through Tailscale" },
        "public":    { label: "SSH pub",   icon: "network-server",     color: Kirigami.Theme.negativeTextColor,
                       text: "Reachable from every network" }
    })
    readonly property var current: info[mode] || { label: "SSH ?", icon: "dialog-question",
                                                    color: Kirigami.Theme.neutralTextColor,
                                                    text: "Mode: " + mode }

    Plasmoid.icon: current.icon
    toolTipMainText: "SSH Mode: " + mode
    toolTipSubText: current.text + "\nClick to change"
    preferredRepresentation: compactRepresentation

    P5Support.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []
        onNewData: (source, data) => {
            disconnectSource(source)
            if (source === root.statusCmd) {
                const out = (data["stdout"] || "").trim()
                root.mode = out.length > 0 ? out : "unknown"
            } else if (source === root.guiCmd) {
                root.guiOpen = false
                connectSource(root.statusCmd)
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: exec.connectSource(root.statusCmd)
    }

    compactRepresentation: MouseArea {
        Layout.minimumWidth: row.implicitWidth + Kirigami.Units.smallSpacing * 2
        Layout.preferredWidth: Layout.minimumWidth
        hoverEnabled: true
        onClicked: {
            if (!root.guiOpen) {
                root.guiOpen = true
                exec.connectSource(root.guiCmd)
            }
        }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: root.current.icon
                color: root.current.color
                isMask: true
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
            }
            PlasmaComponents.Label {
                text: root.current.label
                color: root.current.color
            }
        }
    }

    fullRepresentation: Item {}
}
