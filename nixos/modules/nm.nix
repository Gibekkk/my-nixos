{ lib, pkgs, ... }: {
  networking.networkmanager.enable = true;

  # --- Miracast / Wi-Fi P2P (gnome-network-displays) ---------------------
  #
  # Do NOT set networking.wireless.interfaces: it swaps in a per-interface
  # unit (wpa_supplicant-wlo1) that has the same problem as below.
  #
  # Since NixOS 26.05 wpa_supplicant runs as the unprivileged
  # "wpa_supplicant" user. In that mode it still finds P2P peers (the TV),
  # but NetworkManager never lists them, so GND shows no displays.
  # Running it as root (the rest of the sandboxing is kept) fixes that.
  systemd.services.wpa_supplicant.serviceConfig = {
    User = lib.mkForce "root";
    Group = lib.mkForce "root";
  };

  # The wpa_supplicant module restarts wpa_supplicant whenever a wlan
  # interface appears. Starting a cast creates one (p2p-wlo1-0), so that
  # restart would kill the connection. This later rule clears the restart
  # for P2P group interfaces only; real Wi-Fi adapters keep the old rule.
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "wpa-supplicant-keep-p2p";
      destination = "/lib/udev/rules.d/99-zz-wpa-supplicant-keep-p2p.rules";
      text = ''
        ACTION=="add|remove", SUBSYSTEM=="net", ENV{DEVTYPE}=="wlan", KERNEL=="p2p-*", RUN="${pkgs.coreutils}/bin/true"
      '';
    })
  ];

  # Miracast sink connects back to PC (RTSP)
  networking.firewall = {
    allowedTCPPorts = [ 7236 7250 ];
    allowedUDPPorts = [ 7236 5353 ];
  };
}
