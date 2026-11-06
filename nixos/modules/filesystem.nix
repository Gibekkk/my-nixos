{ pkgs, system, ... }: {
  fileSystems."/home/gibets" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "mode=0700" "uid=1100" "gid=100" "size=4G" ];
  };
}
