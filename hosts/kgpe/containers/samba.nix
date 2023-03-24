# Defines a Samba share for my LAN
{ ... }:
{
  guestConfig = {
    # TODO: generalize this somehow? prepopulate auth instead of needing `smbpasswd`
    users.users.chad = {
      isNormalUser = true;
    };

    services = {
      samba = {
        enable = true;
        extraConfig = ''
          browseable = yes
          smb encrypt = required
        '';
        shares = {
          homes = {
            browseable = "no"; # note: each home will be browseable; the "homes" share will not.
            "read only" = "no";
            "guest ok" = "no";
          };
        };
      };
    };
  };

  # TODO: decouple from my specific disk layout
  hostConfig = {
    bindMounts = {
      "/home/chad" = {
        hostPath = "/tank";
        isReadOnly = false;
      };
    };
  };
}
