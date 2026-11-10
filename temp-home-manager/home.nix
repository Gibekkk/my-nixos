{ config, pkgs, ...}: {
  imports = [
    ./fish.nix
    ./modules/bundle.nix
    ./packages.nix
    ./flatpak/flatpak.nix
  ];

  home = {
    username = "gibets";
    homeDirectory = "/home/gibets";
    stateVersion = "26.05";
  };

  nixpkgs.config.allowUnfree = true;
}
