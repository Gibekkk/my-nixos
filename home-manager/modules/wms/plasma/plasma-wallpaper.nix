{ pkgs, lib, ... }:

let
  # true:  video wallpaper, switched to the static image while the power
  #        profile is "balanced" or "power-saver" (wallpaper-power-switch below)
  # false: always the static image
  liveWallpaper = true;

  pluginId = "luisbocanegra.smart.video.wallpaper.reborn";

  # Same approach as the widgets: fetch the plugin and install its QML package
  svwr = pkgs.stdenvNoCC.mkDerivation {
    pname = "smart-video-wallpaper-reborn";
    version = "git-0b4beb8";
    src = pkgs.fetchFromGitHub {
      owner = "luisbocanegra";
      repo = "plasma-smart-video-wallpaper-reborn";
      rev = "0b4beb873850d5a857fe35af9d63571d9df35e63";
      hash = "sha256-mKDU/CU7BaqyBQpjvFsV20kWKh/b89gIgha8HVh8/OA=";
    };

    # Don't let windows that are demanding attention (and not focused) count
    # toward pausing the video
    postPatch = ''
      substituteInPlace package/contents/ui/TasksModel.qml \
        --replace-fail 'if (filterByActive && !tasksModel.data(currentTask, isActive))' \
'if (tasksModel.data(currentTask, abstractTasksModel.IsDemandingAttention) && !tasksModel.data(currentTask, isActive))
                continue;

            if (filterByActive && !tasksModel.data(currentTask, isActive))'
    '';

    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/plasma/wallpapers/${pluginId}
      cp -r package/metadata.json package/contents $out/share/plasma/wallpapers/${pluginId}/
      runHook postInstall
    '';
  };

  # The video lives in your repo, so it moves with the config
#   video = ../../../../backgrounds/furina-under-dark-skies.1920x1080.mp4;
    video = ../../../../backgrounds/furina-night-sea-genshin-impact-moewalls-com.mp4;

  # First frame of the video (ffmpeg -i <video> -frames:v 1 <png>), used as the
  # static wallpaper
  staticImage = ../../../../backgrounds/furina-night-sea-genshin-impact-moewalls-com.first-frame.png;

  # Follows power-profiles-daemon: "performance" -> video wallpaper,
  # "balanced" / "power-saver" -> static image. Switches through plasmashell's
  # scripting API (the same call plasma-manager uses to set the wallpaper).
  # The video plugin keeps its settings, so switching back resumes it.
  wallpaperPowerSwitch = pkgs.writeShellApplication {
    name = "wallpaper-power-switch";
    runtimeInputs = with pkgs; [ systemd glib.bin coreutils gnused gnugrep ];
    text = ''
      setPlugin() {
        busctl --user call org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell \
          evaluateScript s "$1" >/dev/null
      }

      liveJs='var ds = desktops();
      for (var i = 0; i < ds.length; i++) { ds[i].wallpaperPlugin = "${pluginId}"; }'

      staticJs='var ds = desktops();
      for (var i = 0; i < ds.length; i++) {
        ds[i].wallpaperPlugin = "org.kde.image";
        ds[i].currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
        ds[i].writeConfig("Image", "file://${staticImage}");
      }'

      current=""
      apply() {
        profile=$(busctl --system get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles \
          net.hadess.PowerProfiles ActiveProfile 2>/dev/null | sed -E 's/^s "(.*)"$/\1/') || true
        [ -n "$profile" ] || return 0
        if [ "$profile" = performance ]; then want=live; else want=static; fi
        [ "$want" = "$current" ] && return 0
        if [ "$want" = live ]; then js="$liveJs"; else js="$staticJs"; fi
        if setPlugin "$js"; then
          current="$want"
          echo "power profile '$profile': $want wallpaper"
        fi
      }

      # wait for plasmashell, then give plasma-manager's login scripts a moment
      for _ in $(seq 1 60); do
        busctl --user status org.kde.plasmashell >/dev/null 2>&1 && break
        sleep 1
      done
      sleep 5
      apply

      gdbus monitor --system --dest net.hadess.PowerProfiles --object-path /net/hadess/PowerProfiles \
        | while read -r line; do
            case "$line" in *ActiveProfile*) apply ;; esac
          done
    '';
  };
in
{
  xdg.dataFile."plasma/wallpapers/${pluginId}".source =
    "${svwr}/share/plasma/wallpapers/${pluginId}";

  programs.plasma.workspace.wallpaper = lib.mkIf (!liveWallpaper) staticImage;

  # Lock screen: always the static frame. The login screen (SDDM) uses the
  # same image, set in nixos/modules/plasma.nix.
  # ("${...}" copies just the image to the store, not the whole repo)
  programs.plasma.kscreenlocker.appearance.wallpaper = "${staticImage}";

  systemd.user.services.wallpaper-power-switch = lib.mkIf liveWallpaper {
    Unit = {
      Description = "Static wallpaper on balanced/power-saver, video on performance";
      After = [ "graphical-session.target" "plasma-plasmashell.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${wallpaperPowerSwitch}/bin/wallpaper-power-switch";
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  programs.plasma.workspace.wallpaperCustomPlugin = lib.mkIf liveWallpaper {
    plugin = pluginId;
    config.General = {
      PauseMode = 0;
      VideoUrls = builtins.toJSON [
        {
          filename = "file://${video}";
          enabled = true;
          duration = 0;
          customDuration = 0;
          playbackRate = 0;
          alternativePlaybackRate = 0;
          loop = false;
          dayNightPhase = 4;
        }
      ];

      # Keep playing when the battery is low
      BatteryPausesVideo = false;

      # Never switch to another video (0 = Never)
      ChangeWallpaperMode = 0;
    };
  };
}
