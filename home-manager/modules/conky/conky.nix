{ lib, pkgs, inputs, ... }:
let
  conf = builtins.readFile ./conky.conf;
in
{
  services.conky = {
    enable = true;
    # conky 1.25.3 from unstable: supports own_window_namespace
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.conky;
    extraConfig = conf;
  };
  xdg.configFile."conky/clock.lua".source = ./conky/clock.lua;
}
