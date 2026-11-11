{
  systemd.user.services.conky = {
    Unit = {
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      StartLimitIntervalSec = lib.mkForce 0;
    };
    Service = {
      # Wait for the compositor socket before starting
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'for i in $(seq 1 30); do [ -S \"$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY\" ] && exit 0; sleep 1; done; exit 1'";
      Restart = lib.mkForce "on-failure";
      RestartSec = lib.mkForce 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
