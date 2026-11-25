{ ... }:
let
  # Same still as gibekkk's static wallpaper, login and lock screen
  wallpaper = "${../backgrounds/furina-night-sea-genshin-impact-moewalls-com.first-frame.png}";
in
{
  # Guest profile: gibekkk's shell and KDE setup, without apps or credentials.
  #   fish.nix                - fish aliases/keybinds, fzf, starship
  #   plasma-workspace.nix    - theme, fonts, touchpad, shortcuts, KWin settings
  # Not imported: git identity, chat/music apps, autostart, flatpaks, firefox
  # profile, the video wallpaper and the panel with the SSH Mode widget.
  # Launch shortcuts for gibekkk's own apps (e.g. ZapFast, VSCodium) do
  # nothing here, since those apps are not installed for the guest.
  # Applied at every boot by nixos/modules/guest-home.nix.
  imports = [
    ./fish.nix
    ./modules/wms/plasma/plasma-workspace.nix
  ];

  home = {
    username = "gibets";
    homeDirectory = "/home/gibets";
    stateVersion = "26.05";
  };

  programs.plasma = {
    enable = true;
    workspace.wallpaper = wallpaper;
    kscreenlocker.appearance.wallpaper = wallpaper;
  };
}
