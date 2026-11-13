{ ... }: {
  programs.plasma.enable = true;

  # Restart portals after a crash. Drop-ins extend package units safely.
  xdg.configFile."systemd/user/xdg-desktop-portal.service.d/restart.conf".text = ''
    [Service]
    Restart=on-failure
    RestartSec=2
  '';
  xdg.configFile."systemd/user/plasma-xdg-desktop-portal-kde.service.d/restart.conf".text = ''
    [Service]
    Restart=on-failure
    RestartSec=2
  '';
}
