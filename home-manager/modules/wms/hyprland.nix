{ config, ... }: {
  xdg.configFile."hypr/hyprland.lua" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nix/home-manager/hypr/hyprland.lua";
    force = true;
  };

  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
}
