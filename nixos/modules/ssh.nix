{
  services.openssh.settings = {
    PermitRootLogin = "no";
    AllowUsers = [ "gibekkk" ];

    # PasswordAuthentication = false;
    # KbdInteractiveAuthentication = false;
  };

  users.users.gibekkk.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICr8LR1NoH/XvKGM6AZIYH7EWusMg0M3sA3LbsAlXaqr u0_a430@localhost"
  ];
}
