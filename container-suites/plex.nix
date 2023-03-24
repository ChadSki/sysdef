{ ... }:
{
  guestConfig = {
    nixpkgs.config.allowUnfree = true; # Plex is unfree
    services.plex = {
        enable = true;
        dataDir = "/var/lib/plex";
        openFirewall = true;
        user = "plex";
        group = "plex";
    };
  };

  hostConfig = {
    bindMounts = {
      "/var/lib/plex" = {
        hostPath = "/tank/plex";
        isReadOnly = false;
      };
    };
  };
}
