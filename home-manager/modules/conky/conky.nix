{ lib, pkgs, inputs, ... }:
let
  conf = builtins.readFile ./conky.conf;

  # Wait for Wayland socket before starting conky (max 30 s)
  waitForWayland = pkgs.writeShellScript "conky-wait-wayland" ''
    for i in $(${pkgs.coreutils}/bin/seq 1 30); do
      [ -S "$XDG_RUNTIME_DIR/''${WAYLAND_DISPLAY:-wayland-0}" ] && exit 0
      ${pkgs.coreutils}/bin/sleep 1
    done
    exit 1
  '';
in
{
  services.conky = {
    enable = true;
    # conky 1.25.3 from unstable: supports own_window_namespace
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.conky;
    extraConfig = conf;
  };

  xdg.configFile."clock.lua".source = ./clock.lua;

  systemd.user.services.conky = {
    Unit = {
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      StartLimitIntervalSec = lib.mkForce 0;
    };
    Service = {
      ExecStartPre = "${waitForWayland}";
      Restart = lib.mkForce "on-failure";
      RestartSec = lib.mkForce 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
