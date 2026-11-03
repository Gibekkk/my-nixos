{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
  };
  
  networking.firewall.trustedInterfaces = [ "tailscale0" ]; # Enable tailscale.
  networking.firewall.checkReversePath = "loose"; # Allow tailscale package to be sent.

  services.resolved.enable = true; # Allow tailscale DNS.
}
