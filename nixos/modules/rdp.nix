{ config, lib, pkgs, ... }:
let
  cfg = config.services.rdp;

  # KDE KRDP (invent.kde.org/plasma/krdp): an RDP server streaming the user's
  # live Plasma session. Its exposure mirrors sshmode (off | tailscale | public),
  # including the runtime `sshmode` toggle.
  #
  # This overrides KRDP's own user unit (app-org.kde.krdpserver.service) instead
  # of adding a second one, so System Settings > Remote Desktop and sshmode
  # control the same server and never fight over the port. Logins use the
  # system user (SystemUserEnabled=true in ~/.config/krdpserverrc, set in that
  # settings page).
  krdp = pkgs.kdePackages.krdp;
  unitName = "app-org.kde.krdpserver";

  # Decides how/where to listen based on the current mode.
  # /run/rdpmode is written at runtime by scripts/sshmode.sh (per-boot state,
  # like the sshd.socket drop-in); at boot it falls back to /etc/sshmode/default.
  #
  # --plasma: capture the screen and inject input through KWin's own protocols
  # (allowed by X-KDE-Wayland-Interfaces in org.kde.krdpserver.desktop) instead
  # of the desktop portal, which needs an interactive approval and could not
  # identify the server ("App info not found"), so nothing was streamed.
  krdp-launcher = pkgs.writeShellApplication {
    name = "krdp-launcher";
    runtimeInputs = [ pkgs.coreutils pkgs.iproute2 ];
    text = ''
      mode=""
      if [ -r /run/rdpmode ]; then mode=$(cat /run/rdpmode); fi
      if [ -z "$mode" ] && [ -r /etc/sshmode/default ]; then mode=$(cat /etc/sshmode/default); fi

      run() { exec ${krdp}/bin/krdpserver --plasma --port ${toString cfg.port} "$@"; }

      tailscale_ip() {
        local line kind addr
        line=$(ip -4 -o addr show dev tailscale0 2>/dev/null | head -n1) || return 0
        # "<idx>: tailscale0    inet 100.x.y.z/32 ..." -> 100.x.y.z
        read -r _ _ kind addr _ <<< "$line" || true
        if [ "''${kind:-}" = inet ]; then printf '%s\n' "''${addr%%/*}"; fi
      }

      case "$mode" in
        off)
          echo "krdp: sshmode is off; not starting."
          exit 0
          ;;
        public)
          run
          ;;
        tailscale)
          # tailscaled may still be coming up right after login: wait a bit
          ip_addr=""
          for _ in $(seq 1 30); do
            ip_addr=$(tailscale_ip)
            [ -n "$ip_addr" ] && break
            sleep 2
          done
          if [ -z "$ip_addr" ]; then
            echo "krdp: tailscale0 has no IPv4 address; retrying later." >&2
            exit 1   # Restart=on-failure tries again
          fi
          run --address "$ip_addr"
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
    enable = lib.mkEnableOption "KRDP, an RDP server whose exposure follows sshmode" // {
      default = true;
    };

    port = lib.mkOption {
      type = lib.types.port;
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
    environment.systemPackages = [ krdp ];   # KCM (System Settings > Remote Desktop) + desktop file
    systemd.packages = [ krdp ];             # ships app-org.kde.krdpserver.service

    # Public mode needs the port open; Tailscale traffic already passes via
    # networking.firewall.trustedInterfaces (tailscale0).
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    # Drop-in on the packaged unit (it exists in systemd.packages).
    systemd.user.services.${unitName} = {
      overrideStrategy = "asDropin";
      # Global user unit: only for cfg.user, so a guest login never shares its session
      unitConfig = {
        ConditionUser = cfg.user;
        StartLimitIntervalSec = 300;
        StartLimitBurst = 5;
      };
      wantedBy = [ "plasma-workspace.target" ];
      serviceConfig = {
        ExecStart = [ "" "${krdp-launcher}/bin/krdp-launcher" ];
        Restart = "on-failure";
        RestartSec = 10;
      };
    };
  };
}
