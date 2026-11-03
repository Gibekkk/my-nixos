{ config, pkgs, ... }:
let
  flakeDir = "${config.home.homeDirectory}/nix";
in {
  programs.fish = {
    enable = true;
    shellAliases = {
      rb   = "sudo nixos-rebuild switch --flake ${flakeDir}#Gibekkk";
      hms  = "home-manager switch --flake ${flakeDir}#gibekkk";
      upd  = "nix flake update --flake ${flakeDir}";
      conf = "nvim ${flakeDir}/nixos/configuration.nix";
      ff   = "fastfetch";
    };
    functions.fish_greeting = ''
      echo "Welcome back, $USER" | lolcat
    '';
    plugins = [
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
    ];
  };

  programs.starship.enable = true;
  home.packages = with pkgs; [ fd bat ];
}
