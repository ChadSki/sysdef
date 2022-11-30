# Defines a Nextcloud+Postgres declarative container combo
{ pkgs, ... }:
{
  guestConfig = {
    services = {
      nextcloud = {
        enable = true;
        hostName = "nextcloud.mydomain.test";
        package = pkgs.nextcloud23;

        config = {
          dbtype = "pgsql";
          dbuser = "nextcloud";
          dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
          dbname = "nextcloud";
          dbpassFile = "/var/nextcloud-db-pass";

          adminpassFile = "/var/nextcloud-admin-pass";
          adminuser = "admin";
        };
      };

      postgresql = {
        enable = true;

        # Ensure the database, user, and permissions always exist
        ensureDatabases = [ "nextcloud" ];
        ensureUsers = [
          {
            name = "nextcloud";
            ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
          }
        ];
      };
    };

    # Ensure that postgres is running before running the setup
    systemd.services."nextcloud-setup" = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };
  };

  hostConfig = {
    # Refer to secrets kept outside of the nix store
    bindMounts = {
      "/var/nextcloud-admin-pass" = {
        hostPath = "/var/nextcloud-admin-pass";
        isReadOnly = false;
      };
      "/var/nextcloud-db-pass" = {
        hostPath = "/var/nextcloud-db-pass";
        isReadOnly = false;
      };
    };
  };
}
