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
    hash = "sha256-SQ3TlpmnCRT2pJTZfn/B38xb2ErDHezXFVABWmabzS8=";
  };

  indicatorId = "com.github.dualitykyle.desktopindicator";
  desktopIndicator = mkPlasmoid {
    pname = "plasma-desktop-indicator";
    id = indicatorId;
    owner = "DualityKyle";
    repo = "plasma-desktop-indicator";
    rev = "5092d0e7921b3ab7d0b03032ce14b6d088e7e64f";
    hash = "sha256-gDPh/ABuu4xGdsAunOyiUK64816QxSGxWyqwUe3aXT0=";
  };

  # KVitals profile, copied from the live config (appletsrc) after tuning
  kvitalsProfileId = "c2538c5a-bbbd-4342-9804-10346294af62";
  kvitalsData = {
    pinnedMetrics = "cpu/usage,ram/used,swap/percent,net/down,net/up,temp/system,uptime/uptime";
    cpuEnabled = true;
    cpuSubMetrics = "usage,freq,temp";
    cpuVisibility = "both";
    ramEnabled = true;
    ramSubMetrics = "percentage";
    ramWidgetShowBoth = false;
    ramVisibility = "both";
    ramUnit = "GiB";
    swapEnabled = false;
    swapSubMetrics = "percent,used";
    swapVisibility = "both";
    tempEnabled = true;
    tempLabel = "System";
    tempVisibility = "both";
    tempSensor = "auto";
    tempSelection = "";
    tempLabels = "";
    gpuEnabled = true;
    gpuSubMetrics = "usage,vram,temp";
    gpuVisibility = "both";
    batEnabled = true;
    batSubMetrics = "percentage,power";
    batVisibility = "both";
    netEnabled = true;
    netSubMetrics = "down,up";
    netVisibility = "both";
    diskEnabled = false;
    diskSubMetrics = "read,write";
    diskVisibility = "both";
    fanEnabled = false;
    fanVisibility = "both";
    uptimeEnabled = false;
    uptimeVisibility = "both";
    cpuLabel = "CPU";
    ramLabel = "RAM";
    swapLabel = "SWAP";
    diskLabel = "DSK";
    diskLabels = "";
    netLabel = "NET";
    networkInterface = "auto";
    showNetworkIp = false;
    batteryDevice = "auto";
    batLabel = "BAT";
    gpuSelection = "";
    gpuLabels = "";
    fanLabel = "FAN";
    fanLabels = "";
    coolantLabels = "";
    displayMode = "icons";
    layoutType = "horizontal";
    iconSize = 12;
    mergeFamilyMetrics = true;
    showSeparators = true;
    backgroundType = "default";
    panelPadding = 0;
    cpuIcon = "cpu-symbolic";
    ramIcon = "memory-symbolic";
    swapIcon = "memory-symbolic";
    tempIcon = "temperature-symbolic";
    gpuIcon = "gpu-symbolic";
    batteryIcon = "battery-symbolic";
    powerIcon = "voltage-symbolic";
    networkIcon = "network-symbolic";
    diskIcon = "storage-symbolic";
    fanIcon = "fan-symbolic";
    uptimeIcon = "system-symbolic";
    fontFamily = "monospace";
    fontSize = 0;
    fontBold = false;
    metricOrder = "cpu,ram,swap,temp,gpu,bat,net,disk,fan,uptime";
    updateInterval = 2000;
    useCustomColors = false;
    iconColor = "";
    labelColor = "";
    fontColor = "";
    enableThresholdColors = false;
    warningColor = "#e5a50a";
    criticalColor = "#da4453";
    cpuWarningThreshold = 70;
    cpuCriticalThreshold = 90;
    tempWarningThreshold = 60;
    tempCriticalThreshold = 85;
    systemWarningThreshold = 60;
    systemCriticalThreshold = 85;
    ramWarningThreshold = 70;
    ramCriticalThreshold = 90;
    swapWarningThreshold = 70;
    swapCriticalThreshold = 90;
    ramTempWarningThreshold = 60;
    ramTempCriticalThreshold = 85;
    gpuWarningThreshold = 70;
    gpuCriticalThreshold = 90;
    gpuTempWarningThreshold = 60;
    gpuTempCriticalThreshold = 85;
    batteryWarningThreshold = 30;
    batteryCriticalThreshold = 15;
    diskWarningThreshold = 80;
    diskCriticalThreshold = 90;
    diskTempWarningThreshold = 45;
    diskTempCriticalThreshold = 60;
    coolantTempWarningThreshold = 40;
    coolantTempCriticalThreshold = 50;
    tempUnit = "C";
    networkUnit = "bytes";
    fanUnit = "rpm";
    fanMaxRpm = 2000;
    labelOpacity = 0.65;
    separatorOpacity = 0.4;
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
      # Uncomment to autohide. Options: normalpanel, autohide, dodgewindows, windowsgobelow
      hiding = "autohide";
      # height, floating etc. are stored in plasmashellrc, not in the
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
          # Flat keys (kvitalsData) are what the widget reads at startup.
          # profileList only stores the saved profile, so settings were
          # not applied until "Apply" was clicked manually.
          config.General = kvitalsData // {
            migrationDone = true;
            activeProfileId = kvitalsProfileId;
            profileList = builtins.toJSON {
              version = 1;
              profiles = [
                {
                  id = kvitalsProfileId;
                  name = "Default";
                  createdAt = 1793839303616;
                  isDefault = true;
                  data = kvitalsData;
                }
              ];
            };
          };
        }

        # Task manager: open windows only, nothing pinned
        {
          name = "org.kde.plasma.icontasks";
          config.General = {
            # Empty string = pin nothing. An empty list may write no key,
            # and Plasma then falls back to its default pinned apps.
            launchers = "";
            wheelEnabled = "AdjustVolume";
            # Panel never pops up when a window wants attention
            unhideOnAttention = false;
            # Ignore windows on other virtual desktops
            showOnlyCurrentDesktop = true;
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
