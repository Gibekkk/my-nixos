{ pkgs, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
    #permittedInsecurePackages = ["python-2.7.18.8" "electron-25.9.0"];
  };

  environment.systemPackages = with pkgs; [
    # Desktop apps
    #audacity
    #chromium
    telegram-desktop
    alacritty
    #obs-studio
    rofi
    wofi
    mpv
    kdenlive
    #discord
    gparted
    obsidian
    zoom-us
    pcmanfm-qt
    firefox

    # Coding stuff
    gnumake
    gcc
    nodejs
    (python3.withPackages (ps: with ps; [ requests ]))

    # CLI utils
    nvim
    fastfetch
    file
    tree
    wget
    git
    gh
    btop
    nix-index
    unzip
    scrot
    ffmpeg
    mediainfo
    ranger
    zram-generator
    cava
    zip
    ntfs3g
    yt-dlp
    brightnessctl
    swww
    openssl
    lazygit
    lolcat
    bluez
    bluez-tools

    # GUI utils
    feh
    imv
    dmenu
    #screenkey
    mako
    #gromit-mpx

    # Xorg stuff
    #xterm
    #xclip
    #xorg.xbacklight

    # Wayland stuff
    xwayland
    wl-clipboard
    cliphist

    # WMs and stuff
    herbstluftwm
    hyprland
    seatd
    xdg-desktop-portal-hyprland
    polybar
    waybar

    # Sound
    pipewire
    pulseaudio
    pamixer

    # GPU stuff 
    glaxnimate
    radeontop

    # Screenshotting
    grim
    grimblast
    slurp
    flameshot
    swappy

    # Other
    home-manager
    spice-vdagent
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    papirus-nord
  ];
}
