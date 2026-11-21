{ config, ... }:
let
  mkAutostart = name: displayName: exec: {
    "autostart/${name}.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=${displayName}
      Exec=${exec}
      Icon=${name}
      Terminal=false
      StartupNotify=false
      X-GNOME-Autostart-enabled=true
    '';
  };
in
{
  # Login autostart entries, managed here instead of by the apps.
  #
  # The in-app "Start at login" switches (ZapFast, Vesktop) wrote entries that
  # ran the unwrapped binary from a fixed /nix/store path. Without the Nix
  # wrapper ZapFast crashed with NoWaylandLib as soon as its window opened,
  # Vesktop crashed on start, and the paths broke after an update + GC.
  # These entries go through the wrapped binaries of the home-manager packages.
  #
  # Leave the in-app switches alone: to stop an app autostarting, remove it here.
  xdg.configFile =
    mkAutostart "zapfast" "ZapFast" "${config.programs.zapfast.package}/bin/zapfast --start-hidden"
#     // mkAutostart "vesktop" "Vesktop" "${config.programs.vesktop.package}/bin/vesktop";
}
