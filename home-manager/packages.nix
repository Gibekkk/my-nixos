{ pkgs, pkgs-unstable, inputs, system, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Desktop apps
    telegram-desktop
    vscode
    pkgs-unstable.obsidian
    zoom-us
    inputs.zapfast.packages.${system}.default
    github-desktop
    vesktop
    spotify
    virtualbox
    godot

    # Coding

    # CLI utils

    # GUI utils

    # Wayland

    # Sound

    # GPU

    # Screenshots

    # Other

    # Games
    protonplus
  ];

  hardware.graphics.extraPackages = [ pkgs.rocmPackages.clr.icd ];
}
