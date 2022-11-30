{ ... }:
{
  guestConfig = {
    services = {
      jellyfin = {
        enable = true;
      };
    };
  };

  hostConfig = {
    bindMounts = {
      "/deluge" = {
        hostPath = "/zpool/deluge";
        isReadOnly = false;
      };
    };
  };
}
