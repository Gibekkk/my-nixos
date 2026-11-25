{ ... }:
let
  # Same still as gibekkk's static wallpaper, login and lock screen
  wallpaper = "${../backgrounds/furina-night-sea-genshin-impact-moewalls-com.first-frame.png}";
in
{
  # Trimmed guest profile: the look only. Nothing personal (no git identity,
  # chat/music apps, autostart, app shortcuts, flatpaks or the SSH Mode panel
  # widget). Applied at every boot by nixos/modules/guest-home.nix.
  home = {
    username = "gibets";
    homeDirectory = "/home/gibets";
    stateVersion = "26.05";
  };

  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      colorScheme = "BreezeDark";
      inherit wallpaper;
    };

    kscreenlocker.appearance.wallpaper = wallpaper;

    # Same fonts as gibekkk (Biscuit Glitch is installed system-wide)
    fonts = {
      general     = { family = "Biscuit Glitch"; pointSize = 10; };
      small       = { family = "Biscuit Glitch"; pointSize = 8; };
      toolbar     = { family = "Biscuit Glitch"; pointSize = 10; };
      menu        = { family = "Biscuit Glitch"; pointSize = 10; };
      windowTitle = { family = "Biscuit Glitch"; pointSize = 10; };
      fixedWidth  = { family = "JetBrains Mono"; pointSize = 10; };
    };
  };
}
