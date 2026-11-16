{ pkgs, ... }: {
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;

    settings.mysqld = {
      bind-address = "127.0.0.1";
      port = 3306;
    };

    ensureDatabases = [  ];

    # Linux user gibekkk gets full rights, no password, over the local socket.
    ensureUsers = [{
      name = "gibekkk";
      ensurePermissions = { "*.*" = "ALL PRIVILEGES"; };
    }];
  };

  # phpMyAdmin container on http://localhost:8081
  virtualisation.podman.enable = true;
  virtualisation.oci-containers = {
    backend = "podman";
    containers.phpmyadmin = {
      image = "docker.io/library/phpmyadmin:5";
      extraOptions = [ "--network=host" ];
      environment = {
        PMA_HOST = "127.0.0.1";
        PMA_PORT = "3306";
        APACHE_PORT = "8081";
      };
    };
  };
}
