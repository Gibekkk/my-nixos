{ lib, pkgs, config, ... }:
let
  assign = app: types: lib.genAttrs types (_: app);

  # Default handler for http/https links clicked in other apps (Vesktop,
  # ZapFast, Telegram, ...). Spotify links go to the desktop app through
  # spotify-open (modules/spicetify.nix) so jam links join directly; anything
  # else, or a Spotify link spotify-open cannot handle, opens in Firefox.
  # Links clicked inside Firefox itself stay in Firefox.
  firefox = "${config.programs.firefox.finalPackage}/bin/firefox";
  linkRouter = pkgs.writeShellScript "link-router" ''
    for url in "$@"; do
      case "$url" in
        https://spotify.link/* | https://spotify.app.link/* | http*://open.spotify.com/*)
          if command -v spotify-open >/dev/null && spotify-open "$url"; then
            continue
          fi
          ;;
      esac
      ${firefox} "$url" &
    done
    wait
  '';

  videoTypes = [
    "video/mp4" "video/x-matroska" "video/webm" "video/quicktime"
    "video/x-msvideo" "video/mpeg" "video/ogg" "video/x-flv"
    "video/3gpp" "video/x-ms-wmv" "video/x-m4v" "video/mp2t"
    "application/x-matroska"
  ];
  audioTypes = [
    "audio/mpeg" "audio/flac" "audio/x-flac" "audio/ogg" "audio/x-wav"
    "audio/mp4" "audio/aac" "audio/opus" "audio/x-opus+ogg" "audio/webm"
  ];
  imageTypes = [
    "image/png" "image/jpeg" "image/gif" "image/webp" "image/bmp"
    "image/svg+xml" "image/avif" "image/tiff"
  ];
  archiveTypes = [
    "application/zip" "application/x-tar" "application/gzip"
    "application/x-7z-compressed" "application/vnd.rar"
    "application/x-xz" "application/zstd"
  ];
  webTypes = [
    "text/html" "application/xhtml+xml"
    "x-scheme-handler/about" "x-scheme-handler/unknown"
  ];
  linkTypes = [ "x-scheme-handler/http" "x-scheme-handler/https" ];
  textTypes = [
    "text/plain" "text/markdown" "application/json"
    "text/x-shellscript" "text/x-nix"
  ];
in
{
  # Replace the hand-made ~/.config/mimeapps.list (it lacked the GitHub
  # Desktop sign-in handler) instead of failing on the existing file.
  xdg.configFile."mimeapps.list".force = true;

  xdg.desktopEntries.link-router = {
    name = "Firefox (link router)";
    exec = "${linkRouter} %U";
    icon = "firefox";
    noDisplay = true;
    mimeType = linkTypes;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      assign "mpv.desktop" (videoTypes ++ audioTypes)
      // assign "org.kde.gwenview.desktop" imageTypes
      // assign "org.kde.ark.desktop" archiveTypes
      // assign "firefox.desktop" webTypes
      // assign "link-router.desktop" linkTypes
      // assign "org.kde.kate.desktop" textTypes
      // {
        "application/pdf" = "org.kde.okular.desktop";
        "inode/directory" = "org.kde.dolphin.desktop";

        # GitHub Desktop sign-in
        "x-scheme-handler/x-github-desktop-auth" = "github-desktop.desktop";
        "x-scheme-handler/x-github-desktop-dev-auth" = "github-desktop.desktop";
        "x-scheme-handler/x-github-client" = "github-desktop.desktop";
      };
  };
}
