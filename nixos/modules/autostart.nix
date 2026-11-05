{
  xdg.configFile."autostart/zapfast.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=ZapFast
    Exec=zapfast --start-hidden
    Icon=zapfast
    Terminal=false
    X-KDE-autostart-after=panel
  '';
}
