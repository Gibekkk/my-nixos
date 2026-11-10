{ lib, stdenv, fetchurl, dpkg, autoPatchelfHook, makeWrapper
, wrapGAppsHook3, gtk3, nss, libnotify, libxscrnsaver, libxtst, xdg-utils
, at-spi2-atk, libuuid, libsecret, alsa-lib, mesa, libgbm, libdrm
, cups, libxkbcommon, pango, cairo, xorg, libGL, vulkan-loader, systemd, jdk17 }:

stdenv.mkDerivation rec {
  pname = "sklauncher";
  version = "4.0.57";

  src = fetchurl {
    url = "https://github.com/sklauncher/binaries/releases/download/v${version}/sklauncher_${version}_amd64.deb";
    hash = "sha256-JV9VIgrtOlkTZjOXccYzZOxtc5fRc7tdT2JVcTWj7Ls=";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper wrapGAppsHook3 ];
  buildInputs = [
    gtk3 nss libnotify libxscrnsaver libxtst at-spi2-atk libuuid libsecret
    alsa-lib mesa libgbm libdrm cups libxkbcommon pango cairo
    xorg.libX11 xorg.libXcomposite xorg.libXdamage xorg.libXext
    xorg.libXfixes xorg.libXrandr xorg.libxcb
  ];

  unpackPhase = "dpkg-deb -x $src .";
  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt $out/bin $out/share
    cp -r opt/SKlauncher $out/opt/
    cp -r usr/share/icons $out/share/
    install -Dm644 usr/share/applications/pl.skmedix.sklauncher.desktop \
      $out/share/applications/pl.skmedix.sklauncher.desktop
    substituteInPlace $out/share/applications/pl.skmedix.sklauncher.desktop \
      --replace-fail "/opt/SKlauncher/sklauncher" "$out/bin/sklauncher"
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper $out/opt/SKlauncher/sklauncher $out/bin/sklauncher \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL vulkan-loader systemd libxkbcommon ]} \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils jdk17 ]} \
      --add-flags "--no-sandbox"
  '';

  meta = {
    description = "Minecraft launcher";
    homepage = "https://skmedix.pl";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfree;
  };
}
