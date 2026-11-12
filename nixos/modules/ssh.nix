{
  # SSH server settings (port, AllowUsers, PermitRootLogin, exposure) live in
  # sshmode.nix. This file only holds the keys allowed to log in.

  users.users.gibekkk.openssh.authorizedKeys.keys = [
    # phone (Termux)
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICr8LR1NoH/XvKGM6AZIYH7EWusMg0M3sA3LbsAlXaqr u0_a430@localhost"
  ];

  # Once every device you use has a key here, you can turn off passwords:
  # services.openssh.settings = {
  #   PasswordAuthentication = false;
  #   KbdInteractiveAuthentication = false;
  # };
}
