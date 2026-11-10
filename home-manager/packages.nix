{ pkgs, pkgs-unstable, inputs, system, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Desktop apps
    telegram-desktop
    #vscode
    vscodium
    pkgs-unstable.obsidian
    zoom-us
    inputs.zapfast.packages.${system}.default
    github-desktop
    vesktop
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
    (pkgs.callPackage ../packages/nix/sklauncher.nix { })
  ];
}
