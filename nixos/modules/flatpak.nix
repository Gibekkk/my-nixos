{
    services.flatpak = {
        enable = true;

        remotes = [{
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }];

        update.onActivation = false;
        uninstallUnmanaged = false;
    };

    fonts.fontDir.enable = true;
}
