{ config, pkgs, ...}: {
  imports = [
    ./fish.nix
    ./modules/bundle.nix
    ./packages.nix
    ./modules/flatpak/flatpak.nix
  ];

  # Desktop clock: "rainmeter" (Plasma widget) or "conky" (old overlay); "none" for neither
  custom.desktopClock = "rainmeter";

  home = {
    username = "gibekkk";
    homeDirectory = "/home/gibekkk";
    stateVersion = "26.05";
  };
}
