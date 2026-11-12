 let
  artcraft = {
    appId = "ai.storyteller.artcraft-launcher";
    sha256 = "090y6l58awshf8vha738aanm9a3yd40mq39bdyjfsa7lg57g8kr8";
    bundle = "file://${../../../packages/artcraft-launcher-0.13.0-linux-x86_64.flatpak}";
  };
in {
  services.flatpak = {
    enable = true;

    remotes = [{
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }];

    update.onActivation = false;
    uninstallUnmanaged = true;

    packages = [
      "org.vinegarhq.Sober"
      "com.github.tchx84.Flatseal"
      "org.gnome.NetworkDisplays"
      # H.264 encoder (x264enc) for NetworkDisplays. Must match the
      # freedesktop base of its runtime (GNOME 49 = 25.08); without it
      # Miracast asks for a missing codec plugin.
      "org.freedesktop.Platform.codecs-extra//25.08-extra"
      artcraft
    ];
  };
}
