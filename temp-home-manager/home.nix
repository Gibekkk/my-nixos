{ config, pkgs, ...}: {
  imports = [
    ./fish.nix
    ./modules/bundle.nix
    ./packages
  ];

  home = {
    username = "gibets";
    homeDirectory = "/home/gibets";
    stateVersion = "26.05";
  };

  nixpkgs.config.allowUnfree = true;
}
