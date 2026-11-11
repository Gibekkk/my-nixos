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
      libx11
      libxcursor
      libxext
      libxrandr
      libxxf86vm
      libxi
      libxrender
      libxtst
      libxinerama
      freetype
      fontconfig
    ];
  };
}
