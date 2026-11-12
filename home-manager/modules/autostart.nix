{ config, ... }: {
  # ZapFast starts hidden in the tray at login.
  # force: replaces the autostart file ZapFast writes itself when its
  # "start at login" switch is used (it hardcodes a store path).
  xdg.configFile."autostart/zapfast.desktop" = {
    force = true;
    text = ''
      [Desktop Entry]
      Type=Application
      Name=ZapFast
      Exec=${config.programs.zapfast.package}/bin/zapfast --start-hidden
      Icon=zapfast
      Terminal=false
      X-GNOME-Autostart-enabled=true
      X-KDE-autostart-after=panel
    '';
  };
}
