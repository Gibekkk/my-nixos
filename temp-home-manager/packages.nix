{ pkgs, pkgs-unstable, inputs, system, ... }: {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
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

  fonts.packages = with pkgs; [
    (pkgs.runCommand "biscuit-glitch-font" { } ''
      mkdir -p $out/share/fonts/truetype
      cp ${../fonts/BiscuitGlitch.ttf} $out/share/fonts/truetype/
      '')
  ];
}
