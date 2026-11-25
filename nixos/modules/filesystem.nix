{ config, ... }:
let
  guest = config.users.users.gibets;
in
{
  # Guest home on tmpfs: wiped on every reboot. Owner comes from the user
  # definition (the mount used uid=1100 while gibets is 1001, so after each
  # boot gibets could not enter its own home and SDDM logins failed).
  fileSystems."/home/gibets" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "mode=0700" "uid=${toString guest.uid}" "gid=100" "size=4G" ];
  };
}
