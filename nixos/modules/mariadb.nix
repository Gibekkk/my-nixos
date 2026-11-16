{ config, pkgs, ... }:
let
  dbUser = "gibekkk";
  dbPass = "CHANGE_ME";   # temporary. Visible in the Nix store, so change it later
  mysql = "${config.services.mysql.package}/bin/mysql --socket=/run/mysqld/mysqld.sock";
in {
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;

    settings.mysqld = {
      bind-address = "127.0.0.1";
      port = 3306;
    };

    ensureDatabases = [ "appdb" ];
  };

  # Idempotent: creates or updates both accounts, full rights.
  systemd.services.mysql-user-access = {
    description = "MariaDB accounts for ${dbUser}";
    wantedBy = [ "multi-user.target" ];
    after = [ "mysql.service" ];
    requires = [ "mysql.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${mysql} <<'SQL'
      CREATE USER IF NOT EXISTS '${dbUser}'@'localhost' IDENTIFIED BY '${dbPass}';
      ALTER USER '${dbUser}'@'localhost' IDENTIFIED BY '${dbPass}';
      GRANT ALL PRIVILEGES ON *.* TO '${dbUser}'@'localhost' WITH GRANT OPTION;
      FLUSH PRIVILEGES;
      SQL
    '';
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
