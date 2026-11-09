{ pkgs, ... }:
let
  serverui = pkgs.stdenv.mkDerivation rec {
    pname = "serverui";
    version = "0.3.0";

    src = pkgs.fetchurl {
      url = "https://github.com/rakhechashubham/serverui/releases/download/v${version}/ServerUI-${version}-amd64.deb";
      hash = "sha256-obC6UcUxMLntxvGC9ONrd4FaQQtAncxu2gIx2R8Ft30=";
    };

    nativeBuildInputs = with pkgs; [ dpkg autoPatchelfHook wrapGAppsHook3 ];

    buildInputs = with pkgs; [
      webkitgtk_4_1
      gtk3
      libsoup_3
      glib
      glib-networking
      gdk-pixbuf
      cairo
      dbus
      stdenv.cc.cc.lib
    ];

    unpackCmd = "dpkg-deb -x $curSrc source";
    sourceRoot = "source";

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r usr/bin $out/bin
      cp -r usr/share $out/share
      runHook postInstall
    '';

    meta.mainProgram = "serverui-desktop";
  };
in
{
  home.packages = [ serverui ];
}
