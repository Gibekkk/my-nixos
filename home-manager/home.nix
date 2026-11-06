{ config, pkgs, ...}: {
  imports = [
    ./fish.nix
    ./modules/bundle.nix
    ./packages.nix
    ./modules/flatpak/flatpak.nix
  ];

  home = {
    username = "gibekkk";
    homeDirectory = "/home/gibekkk";
    stateVersion = "26.05";
  };

  nixpkgs.config.allowUnfree = true;
}
