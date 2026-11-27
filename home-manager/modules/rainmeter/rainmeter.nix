{ config, lib, pkgs, ... }:
let
  cfg = config.custom.rainmeter;
  pluginId = "org.gibekkk.rainmeter";

  # Reads the same /proc and /sys files as conky's clock.lua (see stats.sh)
  stats = pkgs.writeShellApplication {
    name = "rainmeter-stats";
    text = builtins.readFile ./stats.sh;
  };

  # The Plasma widget (QML), with the stats command filled in
  plasmoid = pkgs.runCommand "rainmeter-plasmoid" { } ''
    cp -r ${./plasmoid} $out
    chmod -R u+w $out
    substituteInPlace $out/contents/ui/main.qml \
      --replace-fail '@STATS@' '${stats}/bin/rainmeter-stats'
  '';

  # The clock is laid out in clock.lua's 1920x1080 design space. It is placed
  # as several small widgets, each showing one block, so the desktop (icons,
  # right-click menu) stays usable everywhere else. Boxes are in design pixels.
  pieces = [
    { block = "date";  x = 64;   y = 40; w = 380; h = 690; }  # weekday, day, month, year, stats
    { block = "clock"; x = 1570; y = 40; w = 290; h = 460; }  # hour, minutes, AM/PM
  ] ++ lib.optionals cfg.ring [
    { block = "ring"; x = 395;  y = 70; w = 155; h = 560; }   # ring arc left of her face
    { block = "ring"; x = 1275; y = 0; w = 300; h = 220; }    # short arc top right
  ];

  scale = cfg.screenWidth / 1920.0;
  px = v: builtins.floor (v * scale + 0.5);

  mkWidget = p: {
    name = pluginId;
    position = { horizontal = px p.x; vertical = px p.y; };
    size = { width = px p.w; height = px p.h; };
    config.General = {
      inherit (p) block;
      originX = p.x;
      originY = p.y;
      inherit scale;
    };
  };
in
{
  options.custom = {
    desktopClock = lib.mkOption {
      type = lib.types.enum [ "rainmeter" "conky" "none" ];
      default = "rainmeter";
      description = ''
        Which desktop clock to run:
          "rainmeter"  Plasma desktop widget (this module)
          "conky"      the conky overlay (modules/conky/conky.nix)
          "none"       neither
      '';
    };

    rainmeter = {
      screenWidth = lib.mkOption {
        type = lib.types.int;
        default = 1920;
        description = "Screen width in pixels; the 1920x1080 layout is scaled to it.";
      };
      ring = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Draw the ring around the wallpaper's girl.";
      };
    };
  };

  config = lib.mkMerge [
    # Always installed, so it can also be added by hand from "Add Widgets"
    {
      xdg.dataFile."plasma/plasmoids/${pluginId}".source = plasmoid;
    }

    # plasma-manager replaces ALL desktop widgets with this list whenever it
    # changes (widgets added by hand on the desktop are removed then).
    (lib.mkIf (config.custom.desktopClock == "rainmeter") {
      programs.plasma.desktop.widgets = map mkWidget pieces;
    })

    # Switching away: clear the desktop widgets so the clock pieces go away
    (lib.mkIf (config.custom.desktopClock != "rainmeter") {
      programs.plasma.desktop.widgets = [ ];
    })
  ];
}
