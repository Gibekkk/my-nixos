{
  services.flatpak = {
    enable = true;

    remotes = [{
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];

    packages = [
      "org.vinegarhq.Sober"
      "com.github.tchx84.Flatseal"
    ];

    update.onActivation = true;
    uninstallUnmanaged = true;
  };

  fonts.fontDir.enable = true;
  xdg.portal.enable = true;
}
