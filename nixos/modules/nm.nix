{
  networking.networkmanager.enable = true;

  # Removes udev rule that restarts wpa_supplicant on every Wi-Fi device event.
  # Breaks Miracast (gnome-network-displays) P2P discovery and pairing.
  networking.wireless.interfaces = [ "wlo1" ];

  networking.firewall = {
    allowedTCPPorts = [ 7236 7250 ];
    allowedUDPPorts = [ 7236 5353 ];
  };
}
