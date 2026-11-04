{ pkgs, pkgs-unstable, inputs, system, ... }: {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Desktop apps
    telegram-desktop
    #alacritty
    rofi
    wofi
    mpv
    kdePackages.kdenlive
    kdePackages.dolphin
    kdePackages.konsole
    gparted
    obsidian
    zoom-us
    lxqt.pcmanfm-qt
    firefox
    inputs.zapfast.packages.${system}.default
    vencord

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
    fzf

    # GUI utils
    feh
    imv
    mako
    pavucontrol

    # Wayland
    wl-clipboard
    cliphist
    #hyprpaper

    # Sound
    pamixer

    # GPU
    radeontop

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
    steam
  ];

  hardware.graphics.extraPackages = [ pkgs.rocmPackages.clr.icd ];

  fonts.packages = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    font-awesome
    powerline-fonts
    nerd-fonts.symbols-only
  ];
}
