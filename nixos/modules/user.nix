{ pkgs, ... }: {
  programs.fish.enable = true;

  users = {
    defaultUserShell = pkgs.fish;

    users.gibekkk = {
      isNormalUser = true;
      description = "Gilbert Winardy";
      extraGroups = [ "networkmanager" "wheel" "input" "libvirtd" "video" "vboxusers"];
      packages = with pkgs; [];
    };

    users.gibets = {
      isNormalUser = true;
      description = "Guest";
      uid = 1001;   # fixed: the tmpfs home in filesystem.nix is owned by this uid
      extraGroups = [ "networkmanager" "input" "libvirtd" "video" ];
      packages = with pkgs; [];
    };
  };

  # Enable automatic login for the user.
  # services.getty.autologinUser = "gibekkk";
}
