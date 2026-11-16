{ pkgs, ... }: {
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;

    settings.mysqld = {
      bind-address = "127.0.0.1";   # local only
      port = 3306;
    };

    ensureDatabases = [  ];
  };

  # phpMyAdmin (official container), on http://localhost:8081
  virtualisation.podman.enable = true;
  virtualisation.oci-containers = {
    backend = "podman";
    containers.phpmyadmin = {
      image = "docker.io/library/phpmyadmin:5";
      extraOptions = [ "--network=host" ];   # reaches MariaDB on 127.0.0.1
      environment = {
        PMA_HOST = "127.0.0.1";
        PMA_PORT = "3306";
        APACHE_PORT = "8081";
      };
    };
  };
}
