{ pkgs, lib, ... }:

let
  mkContainer = import ./mkContainer.nix { inherit lib; };
in
mkContainer {
  guestConfig = {
    services = {
      deluge = {
        dataDir = "/deluge";
        enable = true;
        web = {
          enable = true;
        };
      };
    };
  };

  hostConfig = {
    bindMounts = {
      "/deluge" = {
        hostPath = "/tank/deluge";
        isReadOnly = false;
      };
    };
  };
}
