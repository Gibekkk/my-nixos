{ pkgs, ... }:
let
  pname = "serverui";
  version = "0.3.0";

  src = pkgs.fetchurl {
    url = "https://github.com/rakhechashubham/serverui/releases/download/v${version}/ServerUI-${version}-x86_64.AppImage";
    hash = "sha256-MtxPRqhoewWXsw+wM1UkkqJqHhu+Ink9VGEu3o1LdzI=";
  };

  contents = pkgs.appimageTools.extract { inherit pname version src; };
in
{
  environment.systemPackages = [
    (pkgs.appimageTools.wrapType2 {
      inherit pname version src;
      extraInstallCommands = ''
        install -Dm444 ${contents}/ServerUI.desktop $out/share/applications/serverui.desktop
        substituteInPlace $out/share/applications/serverui.desktop \
          --replace-fail 'Exec=serverui-desktop' 'Exec=serverui'
        cp -r ${contents}/usr/share/icons $out/share/
      '';
    })
  ];
}
