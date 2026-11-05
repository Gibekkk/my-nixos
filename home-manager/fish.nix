{ config, lib, pkgs, ... }:
let
  flakeDir = "${config.home.homeDirectory}/nix";
in {
  programs.fish = {
    enable = true;
    shellAliases = {
      rb    = "sudo nixos-rebuild switch --flake ${flakeDir}#Gibekkk";
      hms   = "home-manager switch --flake ${flakeDir}#gibekkk";
      upd   = "nix flake update --flake ${flakeDir}";
      conf  = "nvim ${flakeDir}/nixos/configuration.nix";
      ff    = "fastfetch";
      clean = "sudo nix-collect-garbage -d";
    };
    functions.fish_greeting = ''
      echo "Welcome back, $USER" | lolcat
    '';
    plugins = [
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
    ];

    # Custom keybinds. mkAfter runs after fzf's own bindings.
    interactiveShellInit = lib.mkAfter ''
      bind --erase \ct \cr \ec
      bind \cf fzf-file-widget      # Ctrl+F: files
      bind \cr fzf-history-widget   # Ctrl+R: history
      bind \ct fzf-cd-widget        # Ctrl+T: cd
    '';
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --exclude .git";
    fileWidgetOptions = [ "--preview 'bat --color=always --line-range :200 {}'" ];
    changeDirWidgetCommand = "fd --type d --hidden --exclude .git";
  };

  programs.starship.enable = true;
  home.packages = with pkgs; [ fd bat ];
}
