{ pkgs, ... }: {
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zlib
      stdenv.cc.cc.lib
      libGL
      glfw
      openal
      libpulseaudio
      alsa-lib
      udev
      flite
      libxkbcommon
      xorg.libX11
      xorg.libXcursor
      xorg.libXext
      xorg.libXrandr
      xorg.libXxf86vm
      xorg.libXi
      xorg.libXrender
      xorg.libXtst
      xorg.libXinerama
      freetype
      fontconfig
    ];
  };
}
