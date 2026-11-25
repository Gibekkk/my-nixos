{ config, lib, pkgs, ... }:
let
  cfg = config.services.rdp;

  # KDE KRDP (invent.kde.org/plasma/krdp): an RDP server streaming the user's
  # live Plasma session. Package + KCM already in environment.systemPackages
  # (packages.nix); here we run "krdpserver" as a systemd *user* service whose
  # exposure mirrors services.sshmode.default (off | tailscale | public) so it
  # follows SSH on/off state, including the runtime `sshmode` toggle.
  krdp = pkgs.kdePackages.krdp;

  # Launcher: decides how/where to bind based on the current sshmode mode.
  # /run/rdpmode is written at runtime by scripts/sshmode.sh (per-boot state,
  # like the sshd.socket drop-in); at boot it falls back to /etc/sshmode/default.
  krdp-launcher = pkgs.writeShellApplication {
    name = "krdp-launcher";
    runtimeInputs = [ pkgs.coreutils pkgs.iproute2 ];
    text = ''
      mode=""
      [ -r /run/rdpmode ] && mode=$(cat /run/rdpmode)
      if [ -z "$mode" ]; then
        [ -r /etc/sshmode/default ] && mode=$(cat /etc/sshmode/default)
      fi
      case "$mode" in
        off)
          exit 0   # fail closed: nothing listens while SSH is off
          ;;
        public)
          exec ${krdp}/bin/krdpserver --port ${toString cfg.port}
          ;;
        tailscale)
          ip_addr=$(ip -4 -o addr show dev tailscale0 2>/dev/null | head -n1 | awk '{print $4}' | cut -d/ -f1)
          if [ -z "$ip_addr" ]; then
            echo "krdp: mode 'tailscale' but tailscale0 has no address; not starting." >&2
            exit 0
          fi
          exec ${krdp}/bin/krdpserver --address "$ip_addr" --port ${toString cfg.port}
          ;;
        *)
          echo "krdp: unknown mode '$mode'; refusing to start (fail closed)." >&2
          exit 0
          ;;
      esac
    '';
  };
in

{
  options.services.rdp = {
    # On by default; set services.rdp.enable = false to remove the service.
    enable = lib.mkEnableOption "KRDP, an RDP server whose exposure follows services.sshmode.default" // {
      default = true;
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 3389;
      description = "TCP port krdpserver listens on (opened in the firewall by this module).";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "gibekkk";
      description = "Whose Plasma session is shared; the service never starts for other users.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Public mode needs the port through nftables; Tailscale-mode traffic
    # already passes via networking.firewall.trustedInterfaces (tailscale0).
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    systemd.user.services.krdpserver = {
      description = "KRDP server for the current Plasma session (RDP, TCP ${toString cfg.port})";
      # Global user unit: limit it to cfg.user so a guest login cannot start a
      # misconfigured instance (pattern from nixos services.video.wivrn).
      unitConfig.ConditionUser = cfg.user;
      # Session-scoped: starts when a graphical session is up, dies with it.
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${krdp-launcher}/bin/krdp-launcher";
        # on-abnormal: recover from segfaults/timeouts, but do NOT respawn a
        # clean config error (e.g. "no users configured" exits non-zero once at boot).
        Restart = "on-abnormal";
        RestartSec = 2;
      };
    };
  };
}
