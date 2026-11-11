{ pkgs, inputs, ... }:
let
  old = inputs.nixpkgs-2511.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  networking.networkmanager.enable = true;
  networking.wireless.interfaces = [ "wlo1" ];

  # Test: older wpa_supplicant. Revert after.
  nixpkgs.overlays = [
    (final: prev: { wpa_supplicant = old.wpa_supplicant; })
  ];

  networking.firewall = {
    allowedTCPPorts = [ 7236 7250 ];
    allowedUDPPorts = [ 7236 5353 ];
  };
}
