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
  };
}
