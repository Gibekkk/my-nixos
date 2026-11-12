{ pkgs, pkgs-unstable, inputs, system, ... }:
let
  # GitHub Desktop as packaged in nixpkgs cannot finish "Sign in" on Linux:
  #  1. it is upstream desktop/desktop, whose sign-in callback is only handled
  #     through Electron's macOS-only "open-url" event; on Linux the browser
  #     hands the x-github-desktop(-dev)-auth:// URL to the running app as a
  #     "second-instance" argument, which upstream ignores;
  #  2. its launcher is a makeBinaryWrapper that cannot expand the
  #     ''${NIXOS_OZONE_WL:+...} flags, so junk arguments are passed.
  # Fix: same build, a real shell wrapper, and a tiny main.js prelude that
  # forwards such URLs to the existing "open-url" handler.
  ghdUrlPrelude = pkgs.writeText "github-desktop-linux-url.js" ''
    ;(function () {
      const { app } = require("electron");
      const re = /^x-github-(client|desktop-auth|desktop-dev-auth):\/\//;
      app.on("second-instance", (_event, argv) => {
        for (const arg of argv) {
          if (re.test(arg)) app.emit("open-url", { preventDefault() {} }, arg);
        }
      });
    })();
  '';

  github-desktop-fixed = pkgs.symlinkJoin {
    name = "github-desktop-${pkgs.github-desktop.version}";
    paths = [ pkgs.github-desktop ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      app=$out/share/github-desktop/resources/app
      rm $app/main.js
      cat ${ghdUrlPrelude} ${pkgs.github-desktop}/share/github-desktop/resources/app/main.js > $app/main.js

      electron=$(grep -aoE '/nix/store/[a-z0-9]{32}-electron-[0-9.]+/bin/electron' \
        ${pkgs.github-desktop}/bin/github-desktop | head -n1)
      test -x "$electron" || { echo "github-desktop: electron path not found" >&2; exit 1; }

      rm $out/bin/github-desktop
      makeWrapper "$electron" $out/bin/github-desktop \
        --add-flags "$app" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
        --inherit-argv0
    '';
    inherit (pkgs.github-desktop) meta;
  };
in
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-41.10.7"
    "ventoy-gtk3-1.1.12"
  ];

  environment.systemPackages = with pkgs; [
    # Desktop apps
    gnome-network-displays # Miracast; P2P/firewall setup in modules/nm.nix
    kdePackages.kamera

    #alacritty
    mpv
    kdePackages.kdenlive
    kdePackages.dolphin
    kdePackages.konsole
    gparted
    lxqt.pcmanfm-qt
    github-desktop-fixed # see the let-block above (sign-in fix)
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
    pavucontrol

    # Wayland
    wl-clipboard

    # Sound
    pamixer

    # GPU
    radeontop
    vulkan-tools
    mesa-demos
    pascube

    # Screenshots
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
