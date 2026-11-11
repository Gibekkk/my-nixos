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
      artcraft
    ];
  };
}
