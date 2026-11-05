{ config, pkgs, ...}: {
  imports = [
    ./fish.nix
    ./modules/bundle.nix
  ];

  home = {
    username = "gibekkk";
    homeDirectory = "/home/gibekkk";
    stateVersion = "26.05";
  };

  nixpkgs.config.allowUnfree = true;
}
