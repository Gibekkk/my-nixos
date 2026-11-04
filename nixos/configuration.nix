{ inputs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ./modules/bundle.nix
    ./modules/flatpak/flatpak.nix
  ];

  networking.hostName = "Gibekkk"; # Define your hostname.
  
  networking.extraHosts = ''
    100.105.193.52 bobian
    100.116.34.120 imt-ucm
    100.118.106.119 server-alim
    100.84.145.118 syariati
  '';

  time.timeZone = "Asia/Makassar"; # Set your time zone.

  i18n.defaultLocale = "en_US.UTF-8"; # Select internationalisation properties.

  nix.settings.experimental-features = [ "nix-command" "flakes" ]; # Enabling flakes

  system.stateVersion = "26.05"; # Don't change it bro
}
