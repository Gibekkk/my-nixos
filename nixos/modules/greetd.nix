{ pkgs, ... }: {
  services.greetd = {
    enable = true;
    useTextGreeter = true;   # stops boot logs painting over greeter
    settings.default_session = {
      user = "greeter";
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions /run/current-system/sw/share/wayland-sessions";
    };
  };
}
