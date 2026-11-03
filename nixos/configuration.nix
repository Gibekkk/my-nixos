{ inputs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ./modules/bundle.nix
    ./modules/flatpak/flatpak.nix
  ];

  disabledModules = [
    ./modules/xserver.nix
    ./modules/hyprland.nix
  ];

  networking.hostName = "Gibekkk"; # Define your hostname.
  
  networking.extraHosts = ''
    100.64.0.10 nas
    100.64.0.11 server
  '';

  time.timeZone = "Asia/Makassar"; # Set your time zone.

  i18n.defaultLocale = "en_US.UTF-8"; # Select internationalisation properties.

  nix.settings.experimental-features = [ "nix-command" "flakes" ]; # Enabling flakes

  system.stateVersion = "26.05"; # Don't change it bro
}
