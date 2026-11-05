{ pkgs, ... }:

let
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
  video = ../../backgrounds/furina-under-dark-skies.1920x1080.mp4;
in
{
  xdg.dataFile."plasma/wallpapers/${pluginId}".source =
    "${svwr}/share/plasma/wallpapers/${pluginId}";

  programs.plasma.workspace.wallpaperCustomPlugin = {
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
