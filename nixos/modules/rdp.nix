{ config, lib, pkgs, ... }:
let
  cfg = config.services.rdp;

  # KDE KRDP (invent.kde.org/plasma/krdp): an RDP server that streams the
  # user's live Plasma session over TCP. Already in environment.systemPackages
  # (packages.nix); here we only run its "krdpserver" binary as a systemd
  # user service, like upstream does with app-org.kde.krdpserver.
  krdp = pkgs.kdePackages.krdp;
in
{
  options.services.rdp = {
    enable = lib.mkEnableOption "KRDP, an RDP server for the Plasma desktop";

    port = lib.mkOption {
      type = lib.types.int;
      default = 3389;
      description = "TCP port krdpserver listens on (already opened in modules/nm.nix).";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "gibekkk";
      description = "Whose Plasma session is shared; the service will not start for any other user.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.krdpserver = {
      description = "KRDP server for the current Plasma session (RDP, TCP ${toString cfg.port})";
      # User-wide unit from /etc/systemd/user: restrict it to cfg.user so a
      # guest login cannot crash-loop krdpserver with no KCM config (pattern
      # taken from nixos services.video.wivrn).
      unitConfig.ConditionUser = cfg.user;
      # Lives in the login session: starts once a graphical session is up
      # (SDDM + plasma-wayland), dies with it.
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${krdp}/bin/krdpserver --port ${toString cfg.port}";
        # Recover from crashes; a normal session-logout exit(0) must not respawn.
        Restart = "on-failure";
        RestartSec = 2;
      };
      # First run: configure the login identity in System Settings →
      # Security & Privacy → Remote Desktop (KCM), otherwise krdpserver
      # exits with "No users configured for login".
    };
  };
}
