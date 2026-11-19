{ pkgs, config, inputs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  spotify = config.programs.spicetify.spicedSpotify;

  # Open a Spotify link (jam/socialsession, track, playlist, ...) in the desktop app.
  #
  # The desktop entry from the package runs `spotify %U`, and Spotify ignores a
  # link passed that way. Tested ways that work:
  #   - Spotify already running: MPRIS OpenUri on its D-Bus name
  #   - Spotify not running:     start it with --uri=<link>
  # Also accepts https://spotify.link/... and https://open.spotify.com/... links
  # and turns them into spotify: URIs.
  spotifyOpen = pkgs.writeShellApplication {
    name = "spotify-open";
    runtimeInputs = with pkgs; [ curl systemd gnused gnugrep ];
    text = ''
      link="''${1:-}"
      if [ -z "$link" ]; then
        echo "usage: spotify-open <spotify:... | https://open.spotify.com/... | https://spotify.link/...>" >&2
        exit 2
      fi

      # spotify.link short links redirect to open.spotify.com with the real
      # link URL-encoded in the query string.
      case "$link" in
        https://spotify.link/* | https://spotify.app.link/*)
          link=$(curl -sSL -o /dev/null -w '%{url_effective}' \
            -A 'Mozilla/5.0 (X11; Linux x86_64)' "$link")
          ;;
      esac

      case "$link" in
        spotify:*)
          uri="$link"
          ;;
        *)
          decoded=$(printf '%s' "$link" | sed -e 's/%2[Ff]/\//g' -e 's/%3[Aa]/:/g' -e 's/%3[Ff]/?/g')
          path=$(printf '%s' "$decoded" \
            | grep -oE 'open\.spotify\.com/(intl-[A-Za-z-]+/)?[a-z_]+/[A-Za-z0-9]+' | head -n 1 || true)
          if [ -z "$path" ]; then
            echo "spotify-open: not a Spotify link: $1" >&2
            exit 1
          fi
          path="''${path#open.spotify.com/}"
          path="''${path#intl-*/}"
          uri="spotify:''${path%%/*}:''${path#*/}"
          ;;
      esac

      if busctl --user status org.mpris.MediaPlayer2.spotify >/dev/null 2>&1; then
        busctl --user call org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 \
          org.mpris.MediaPlayer2.Player OpenUri s "$uri"
      else
        exec ${spotify}/bin/spotify --uri="$uri"
      fi
    '';
  };
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.spicetify ];

  programs.spicetify = {
    enable = true;
#     theme = spicePkgs.themes.sleek;
#     colorScheme = "Nord";

    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle
    ];
  };

  home.packages = [ spotifyOpen ];

  # Handler for spotify: links (the "Open Spotify" button on Spotify web pages,
  # links from other apps). Hidden from the app menu.
  xdg.desktopEntries.spotify-open = {
    name = "Spotify (open link)";
    exec = "spotify-open %u";
    icon = "spotify-client";
    noDisplay = true;
    mimeType = [ "x-scheme-handler/spotify" ];
  };
  xdg.mimeApps.defaultApplications."x-scheme-handler/spotify" = "spotify-open.desktop";
}
