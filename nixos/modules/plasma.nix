{ lib, ... }: {
  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.displayManager.defaultSession = "plasma";

  # --- Crash handling / self-recovery -------------------------------------

  # Dr. Konqi (KDE crash reporter) processes every coredump. When apps die at
  # logout it cannot reach the (already gone) session, times out, crashes
  # itself and leaves failed drkonqi-coredump-processor@ units behind.
  # Unhook it; crashes are still recorded by systemd-coredump (coredumpctl).
  systemd.services."drkonqi-coredump-processor@".wantedBy = lib.mkForce [ ];

  # These portals have Restart=no upstream: one crash and file dialogs,
  # screen sharing and app autostart requests stay broken until re-login.
  systemd.user.services = lib.genAttrs [ "xdg-desktop-portal" "plasma-xdg-desktop-portal-kde" ] (_: {
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 2;
    };
  });

#     systemd.user.services.xdg-desktop-portal.serviceConfig = {
#       Restart = "on-failure";
#       RestartSec = 2;
#     };
}
