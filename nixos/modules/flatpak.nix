{
    services.flatpak = {
        enable = true;

        remotes = [{
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }];

        update.onActivation = false;
        uninstallUnmanaged = true;
    };

    fonts.fontDir.enable = true;
}
