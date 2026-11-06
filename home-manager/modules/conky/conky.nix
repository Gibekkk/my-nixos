{ lib, pkgs, inputs, ... }:
let
  conf = builtins.readFile ./conky/conky.conf;
in
{
  assertions = [
    {
      assertion = lib.hasInfix "conky.text" conf;
      message = "home-manager/modules/conky/conky.conf has no conky.text block";
    }
  ];

  services.conky = {
    enable = true;
    # conky 1.25.3 from unstable: supports own_window_namespace
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.conky;
    extraConfig = conf;
  };
}
