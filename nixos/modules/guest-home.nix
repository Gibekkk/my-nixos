{ inputs, ... }:
{
  # Guest account (gibets): home-manager applied by the system, not by the user.
  #
  # /home/gibets is a tmpfs (filesystem.nix), wiped on every boot, so a
  # standalone home-manager config would have to be switched again after each
  # boot, and gibets cannot even read the flake (git refuses repos owned by
  # another user). Through this module the guest's config is built with the
  # system and the home-manager-gibets service re-applies it at every boot.
  # Change it with a system rebuild (rb), not hms.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];
    users.gibets = import ../../home-manager/guest.nix;
  };
}
