{ pkgs, ... }: {
  programs.fish.enable = true;

  users = {
    defaultUserShell = pkgs.fish;

    users.gibekkk = {
      isNormalUser = true;
      description = "Gilbert Winardy";
      extraGroups = [ "networkmanager" "wheel" "input" "libvirtd" ];
      packages = with pkgs; [];
    };

    users.gibets = {
      isNormalUser = true;
      description = "Gilbert Temporary";
      extraGroups = [ "networkmanager" "wheel" "input" "libvirtd" ];
      packages = with pkgs; [];
      uid = 1100;
    };
  };

  fileSystems."/home/temp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "mode=0700" "uid=1100" "gid=100" "size=4G" ];
  };

  # Enable automatic login for the user.
  # services.getty.autologinUser = "gibekkk";
}
