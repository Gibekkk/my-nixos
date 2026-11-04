{
  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      colorScheme = "BreezeDark";
    };

    shortcuts = {
      kwin."Window Close" = "Alt+Q";
    };

    fonts = {
      general     = { family = "Biscuit Glitch"; pointSize = 10; };
      small       = { family = "Biscuit Glitch"; pointSize = 8; };
      toolbar     = { family = "Biscuit Glitch"; pointSize = 10; };
      menu        = { family = "Biscuit Glitch"; pointSize = 10; };
      windowTitle = { family = "Biscuit Glitch"; pointSize = 10; };
      # leave fixedWidth on a monospace font so terminals and code stay readable
      fixedWidth  = { family = "JetBrains Mono"; pointSize = 10; };
    };

    # Any raw KDE config file setting
    #configFile = {
    #  "kwinrc"."Windows"."FocusPolicy" = "FocusFollowsMouse";
    #};
  };
}
