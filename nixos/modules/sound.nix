{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # Stops logout crash in the X11 bell module
    extraConfig.pipewire."10-no-x11-bell" = {
      "context.properties" = {
        "module.x11.bell" = false;
      };
    };

    # Keep the last used output/input and their volumes across logins.
    # WirePlumber saves them in ~/.local/state/wireplumber (default-nodes,
    # default-routes); the settings below make that explicit and stop
    # Bluetooth speakers from overriding the saved volume.
    wireplumber.extraConfig."51-remember-audio" = {
      "wireplumber.settings" = {
        "node.restore-default-targets" = true; # last chosen speaker / mic
        "device.restore-routes" = true;        # per-device volume + mute
        "device.restore-profile" = true;
        "node.stream.restore-props" = true;    # per-app volume
        # A device seen for the first time starts quiet, not loud
        "device.routes.default-sink-volume" = 0.064; # ~40 %
      };
      # Bluetooth "absolute volume" lets the speaker push its own level
      # (often 100 %) on every reconnect. Use PipeWire's software volume
      # instead, so the saved level is restored.
      "monitor.bluez.properties" = {
        "bluez5.enable-hw-volume" = false;
      };
    };
  };
}
