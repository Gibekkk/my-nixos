{ lib, pkgs, pkgs-unstable, inputs, system, ... }: {
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
    # zapfast: installed by programs.zapfast (modules/zapfast.nix)
    # github-desktop: installed system-wide (nixos/packages.nix, patched for sign-in)
    vesktop
    godot
    nur.repos.mio.futo-notes
    winbox


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
