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

    # Any raw KDE config file setting
    #configFile = {
    #  "kwinrc"."Windows"."FocusPolicy" = "FocusFollowsMouse";
    #};
  };
}
