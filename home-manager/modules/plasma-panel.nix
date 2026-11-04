# Declarative Plasma panel, translated from plasma-org.kde.plasma.desktop-appletsrc
#
# Import this from home-manager/modules/bundle.nix as ./plasma-panel.nix
{ pkgs, lib, ... }:

let
  # Package a KDE Store plasmoid (a repo with metadata.json + contents/ at its root)
  mkPlasmoid =
    { pname, id, owner, repo, rev, hash }:
    pkgs.stdenvNoCC.mkDerivation {
      inherit pname;
      version = builtins.substring 0 7 rev;
      src = pkgs.fetchFromGitHub { inherit owner repo rev hash; };
      dontBuild = true;
      installPhase = ''
        runHook preInstall
        mkdir -p $out/share/plasma/plasmoids/${id}
        cp -r metadata.json contents $out/share/plasma/plasmoids/${id}/
        runHook postInstall
      '';
    };

  kvitalsId = "org.kde.plasma.kvitals";
  kvitals = mkPlasmoid {
    pname = "kvitals";
    id = kvitalsId;
    owner = "yassine20011";
    repo = "kvitals";
    rev = "d8eef578dcd7f00799daa3c9567ed59a18738d71";
    hash = lib.fakeHash; # replace with the "got:" hash from the first build error
  };

  indicatorId = "com.github.dualitykyle.desktopindicator";
  desktopIndicator = mkPlasmoid {
    pname = "plasma-desktop-indicator";
    id = indicatorId;
    owner = "DualityKyle";
    repo = "plasma-desktop-indicator";
    rev = "5092d0e7921b3ab7d0b03032ce14b6d088e7e64f";
    hash = lib.fakeHash; # replace with the "got:" hash from the first build error
  };
in
{
  # Install the two KDE Store widgets where Plasma looks for user plasmoids
  xdg.dataFile."plasma/plasmoids/${kvitalsId}".source =
    "${kvitals}/share/plasma/plasmoids/${kvitalsId}";
  xdg.dataFile."plasma/plasmoids/${indicatorId}".source =
    "${desktopIndicator}/share/plasma/plasmoids/${indicatorId}";

  programs.plasma.panels = [
    {
      location = "bottom";
      # height, hiding, floating etc. are stored in plasmashellrc, not in the
      # file I was given, so they are left at their defaults here.
      widgets = [
        # Application launcher
        "org.kde.plasma.kickoff"

        # Desktop indicator (KDE Store)
        {
          name = indicatorId;
          config = {
            Appearance = {
              dotStyle = "pill";
              indicatorCustomColorsOn = true;
              indicatorSizeMode = "custom";
            };
            General.leftClickAction = "none";
          };
        }

        # KVitals (KDE Store)
        {
          name = kvitalsId;
          config.General = {
            pinnedMetrics = "cpu/usage/usage,ram/system,swap/percentage,temp/percent,net/down,net/up,uptime/uptime";
          };
        }

        # Task manager (nothing pinned, mouse wheel adjusts volume)
        {
          name = "org.kde.plasma.icontasks";
          config.General = {
            launchers = [ ];
            wheelEnabled = "AdjustVolume";
          };
        }

        "org.kde.plasma.marginsseparator"

        # System tray with Plasma's default set of items
        "org.kde.plasma.systemtray"

        "org.kde.plasma.digitalclock"
        "org.kde.plasma.showdesktop"
      ];
    }
  ];
}
