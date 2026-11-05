{ pkgs, lib, ... }:

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
      hash = lib.fakeHash; # replace with the "got:" hash from the first build error
    };
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
    };
  };
}
