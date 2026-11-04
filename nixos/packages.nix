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
    vulkan-tools
    glxinfo
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
  ];

  hardware.graphics.extraPackages = [ pkgs.rocmPackages.clr.icd ];

  fonts.packages = with pkgs; [
    (pkgs.runCommand "biscuit-glitch-font" { } ''
      mkdir -p $out/share/fonts/truetype
      cp ${../fonts/BiscuitGlitch.ttf} $out/share/fonts/truetype/
      '')
  ];
}
