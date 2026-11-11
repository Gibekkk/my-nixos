{ pkgs, ... }: {
  networking.networkmanager.enable = true;

  # Miracast sink connects back to PC
  networking.firewall = {
    allowedTCPPorts = [ 7236 7250 ];
    allowedUDPPorts = [ 7236 5353 ];
  };
}
