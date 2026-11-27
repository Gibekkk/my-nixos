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

  # conky 1.25.3 (supports own_window_namespace; 26.05 only has 1.22.3).
  # Built from nixpkgs-unstable's recipe but with 26.05's compiler and
  # libraries (callPackage with our pkgs), so the patched build below reuses
  # the toolchain already installed instead of downloading unstable's.
  #
  # Patched to be click-through: the Wayland backend never sets an input
  # region, so the full-screen (1920x1080) surface took every click, even on
  # transparent pixels, and blocked the desktop (most visibly in Edit Mode).
  # conky only draws, so give the surface an empty input region.
  # --replace-fail stops the build if a newer conky changes this code.
  conkyClickThrough =
    # lua: conky needs >= 5.3 (the default `lua` is 5.1 and configure fails).
    # Unstable passes lua5_5, but 26.05's CMake 4.1 FindLua only knows up to
    # 5.4, so use lua5_4 here.
    (pkgs.callPackage "${inputs.nixpkgs-unstable}/pkgs/os-specific/linux/conky/default.nix" {
      lua = pkgs.lua5_4;
    }).overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace src/output/display-wayland.cc \
          --replace-fail \
            'wl_surface *surface = wl_compositor_create_surface(wl_globals.compositor);' \
            'wl_surface *surface = wl_compositor_create_surface(wl_globals.compositor);
          {
            wl_region *no_input = wl_compositor_create_region(wl_globals.compositor);
            wl_surface_set_input_region(surface, no_input);
            wl_region_destroy(no_input);
          }'
      '';
    });

  # Hide conky while Plasma's Edit Mode is on (it would still be drawn over
  # the shrunken desktop), show it again when Edit Mode ends.
  # Hides instead of stopping: stopping/restarting recreated the full-screen
  # surface and made the desktop lag. clock.lua draws nothing while the flag
  # file exists (shows up within one update_interval).
  # plasmashell has an editMode D-Bus property but sends no change signal
  # (tested), so poll it once a second; one busctl call is negligible.
  conkyEditMode = pkgs.writeShellApplication {
    name = "conky-editmode";
    runtimeInputs = with pkgs; [ systemd coreutils ];
    text = ''
      flag="''${XDG_RUNTIME_DIR:-/tmp}/conky-hidden"
      rm -f "$flag"
      trap 'rm -f "$flag"' EXIT
      last=""
      while true; do
        mode=$(busctl --user get-property org.kde.plasmashell /PlasmaShell \
          org.kde.PlasmaShell editMode 2>/dev/null || true)
        if [ "$mode" != "$last" ]; then
          if [ "$mode" = "b true" ]; then touch "$flag"; else rm -f "$flag"; fi
          last="$mode"
        fi
        sleep 1
      done
    '';
  };
in
{
  services.conky = {
    enable = true;
    package = conkyClickThrough;
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
      # always: also come back after being killed (SIGTERM counts as a clean
      # exit, so on-failure never restarted it). `systemctl --user stop conky`
      # still stops it for good.
      Restart = lib.mkForce "always";
      RestartSec = lib.mkForce 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.conky-editmode = {
    Unit = {
      Description = "Hide conky while Plasma Edit Mode is on";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${conkyEditMode}/bin/conky-editmode";
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
