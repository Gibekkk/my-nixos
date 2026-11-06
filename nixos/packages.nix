{ pkgs, pkgs-unstable, inputs, system, ... }: {
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-41.10.7"
    "ventoy-gtk3-1.1.12"
  ];

  environment.systemPackages = with pkgs; [
    # Desktop apps
    telegram-desktop
    vscode
    #alacritty
    rofi
    wofi
    mpv
    kdePackages.kdenlive
    kdePackages.dolphin
    kdePackages.konsole
    gparted
    pkgs-unstable.obsidian
    zoom-us
    lxqt.pcmanfm-qt
    #firefox
    inputs.zapfast.packages.${system}.default
    github-desktop
    vesktop
    kdePackages.kcalc
    spotify
    virtualbox
    godot
    ventoy-full-gtk
    impression

    # Coding
    gnumake
    gcc
    nodejs
    (python3.withPackages (ps: with ps; [ requests ]))

    # CLI utils
    xsel
    xclip
    fastfetch
    file
    tree
    wget
    git
    gh
    btop
    nix-index
    unzip
    zip
    ffmpeg
    mediainfo
    ranger
    cava
    ntfs3g
    yt-dlp
    brightnessctl
    openssl
    lazygit
    lolcat
    bluez-tools
    fzf
    fd
    bat
    vim
    calc
    fzf

    # GUI utils
    feh
    imv
    mako
    pavucontrol
    #spicetify

    # Wayland
    wl-clipboard
    cliphist
    #hyprpaper

    # Sound
    pamixer

    # GPU
    radeontop
    vulkan-tools
    mesa-demos
    pascube

    # Screenshots
    grim
    grimblast
    slurp
    swappy
    flameshot

    # Other
    home-manager
    spice-vdagent
    papirus-nord

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
