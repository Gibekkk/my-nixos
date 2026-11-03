{ pkgs, ... }: {
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gtk # optional, helpful for GTK app compatibility
    ];
    # Optional: force specific backends if needed
    config.common.default = "kde";
  };
}

