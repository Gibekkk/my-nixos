{ config, lib, pkgs, ... }:
let
  cfg = config.custom.rainmeter;
  enabled = config.custom.desktopClock == "rainmeter";
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

  # The clock is laid out in clock.lua's 1920x1080 design space and placed as
  # two widgets; each draws whatever part of the scene falls in its own area,
  # so the rest of the desktop (icons, right-click menu) stays usable.
  # Plasma's desktop keeps widgets on a 16 px grid and moves overlapping ones
  # when it reloads, so these boxes must stay non-overlapping and on the grid
  # (boxes in design pixels):
  pieces = [
    { x = 64;   y = 32; w = 512; h = 704; }   # date, month, year, stats + left ring arc
    { x = 1264; y = 0;  w = 608; h = 496; }   # hour, minutes, AM/PM + right ring arc
  ];

  scale = cfg.screenWidth / 1920.0;
  grid = v: 16 * builtins.floor (v * scale / 16 + 0.5);   # scaled, snapped to the grid

  # Desktop geometry (screen pixels) and widget settings of each piece
  placed = map (p: rec {
    x = grid p.x;
    y = grid p.y;
    w = grid p.w;
    h = grid p.h;
    # where the widget really sits, back in design space, so the drawing
    # stays aligned with the wallpaper even after snapping
    originX = x / scale;
    originY = y / scale;
  }) pieces;

  wantedJson = builtins.toJSON (if enabled then placed else [ ]);

  # Plasma desktop scripts (plasmashell's evaluateScript). Kept free of single
  # quotes: they are passed to qdbus in single quotes below.
  #
  # check: prints "ok" when the desktop already holds exactly the wanted
  # pieces at their geometry, otherwise "fix"
  checkJs = ''
    var want = ${wantedJson};
    var ok = true;
    desktops().forEach(function (d) {
      var ws = d.widgets();
      var mine = ws.filter(function (w) { return w.type == "${pluginId}"; });
      var others = ws.length - mine.length;
      if (mine.length != want.length || (${lib.boolToString enabled} && others > 0)) { ok = false; return; }
      want.forEach(function (p) {
        var hit = mine.some(function (w) {
          var g = w.geometry;
          return Math.abs(g.x - p.x) < 2 && Math.abs(g.y - p.y) < 2 &&
                 Math.abs(g.width - p.w) < 2 && Math.abs(g.height - p.h) < 2;
        });
        if (!hit) ok = false;
      });
    });
    print(ok ? "ok" : "fix");
  '';

  # remove: in rainmeter mode every desktop widget (the layout is fully
  # declarative); otherwise only the clock pieces
  removeJs = ''
    desktops().forEach(function (d) {
      d.widgets().forEach(function (w) {
        if (${lib.boolToString enabled} || w.type == "${pluginId}") w.remove();
      });
    });
  '';

  addJs = ''
    var want = ${wantedJson};
    desktops().forEach(function (d) {
      want.forEach(function (p) {
        var w = d.addWidget("${pluginId}", p.x, p.y, p.w, p.h);
        w.currentConfigGroup = ["General"];
        w.writeConfig("originX", p.originX);
        w.writeConfig("originY", p.originY);
        w.writeConfig("scale", ${toString scale});
        w.writeConfig("ring", ${lib.boolToString cfg.ring});
      });
    });
  '';
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

  config = {
    # Always installed, so it can also be added by hand from "Add Widgets"
    xdg.dataFile."plasma/plasmoids/${pluginId}".source = plasmoid;

    # Fully declarative layout, checked at every login (runAlways).
    # Plasma 6 ignores geometry changes from scripts, and removing a widget
    # finishes a moment later (removing and re-adding in one go let the new
    # pieces get squeezed next to the dying ones). So:
    #   - already exactly right: do nothing (the normal case; Plasma restores
    #     the pieces itself since they are on the grid and do not overlap)
    #   - otherwise: remove, wait for the removal to finish, then add.
    # This never leaves duplicates. In rainmeter mode, widgets added by hand on
    # the desktop are removed at the next login; in conky/none mode only the
    # clock pieces are removed.
    programs.plasma.startup.startupScript."rainmeter_layout" = {
      runAlways = true;
      priority = 4;
      text = ''
        qd() { qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$1"; }
        state=$(qd '${checkJs}')
        if [ "$state" != ok ]; then
          echo "rainmeter: (re)placing the desktop clock widgets"
          qd '${removeJs}'
          sleep 3
          qd '${addJs}'
        fi
      '';
    };
  };
}
