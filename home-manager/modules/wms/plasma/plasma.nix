{
  programs.plasma = {
    enable = true;
  };

  systemd.user.services = lib.genAttrs [ "xdg-desktop-portal" "plasma-xdg-desktop-portal-kde" ] (_: {
  serviceConfig = { Restart = "on-failure"; RestartSec = 2; };
});
}
