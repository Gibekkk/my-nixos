{ pkgs, pkgs-unstable, inputs, system, ... }: {
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-41.10.7"
    "ventoy-gtk3-1.1.12"
  ];

  environment.systemPackages = with pkgs; [
    # Desktop apps
#     gnome-network-displays

    #alacritty
    rofi
    wofi
    mpv
    kdePackages.kdenlive
    kdePackages.dolphin
    kdePackages.konsole
    gparted
    lxqt.pcmanfm-qt
    github-desktop
    kdePackages.kcalc
    ventoy-full-gtk
    impression

    # Coding
    gnumake
    gcc
    nodejs
    (python3.withPackages (ps: with ps; [ requests ]))
    opencode

    # CLI utils
    xsel
    glib
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
    psmisc

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
    wine
    pciutils
    iw
    usbutils

    # Gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  hardware.graphics.extraPackages = [ pkgs.rocmPackages.clr.icd ];

  fonts.packages = with pkgs; [
    poppins
    texlivePackages.cormorantgaramond
    (pkgs.runCommand "biscuit-glitch-font" { } ''
      mkdir -p $out/share/fonts/truetype
      cp ${../fonts/BiscuitGlitch.ttf} $out/share/fonts/truetype/
      '')
  ];
}
