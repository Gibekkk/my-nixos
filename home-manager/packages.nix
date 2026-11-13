{ pkgs, pkgs-unstable, inputs, system, ... }: {
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowInsecurePredicate = pkg: builtins.elem (lib.getName pkg) [
    "pnpm"
  ];

  home.packages = with pkgs; [
    # Desktop apps
    telegram-desktop
    #vscode
    vscodium
    #pkgs-unstable.obsidian
    zoom-us
    inputs.zapfast.packages.${system}.default
    # github-desktop: installed system-wide (nixos/packages.nix, patched for sign-in)
    vesktop
    virtualbox
    godot
    nur.repos.mio.futo-notes


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
