{ config, pkgs, ... }:
let
  flakeDir = "${config.home.homeDirectory}/nix";
in {
  programs.fish = {
    enable = true;

    shellAliases = {
      rb   = "sudo nixos-rebuild switch --flake ${flakeDir}";
      upd  = "nix flake update --flake ${flakeDir}";
      upg  = "nix flake update --flake ${flakeDir}; and sudo nixos-rebuild switch --flake ${flakeDir}";
      hms  = "home-manager switch --flake ${flakeDir}";
      conf = "nvim ${flakeDir}/nixos/configuration.nix";
      pkgs = "nvim ${flakeDir}/nixos/packages.nix";
      ff   = "fastfetch";
    };

    # Git Stuff
    #shellAbbrs = {
    #  gs = "git status";
    #  ga = "git add";
    #  gc = "git commit";
    #  gp = "git push";
    #  gl = "git log --oneline";
    #  gd = "git diff";
    #};

    programs.fish.functions.fish_greeting = ''
      echo "Welcome back, $USER" | lolcat
    '';
    
    home.packages = with pkgs; [ lolcat fzf fd bat ];

    # Optional extras
    plugins = [
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
    ];
  };

  # Replaces agnoster theme
  programs.starship.enable = true;
}
