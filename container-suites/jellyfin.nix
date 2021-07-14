{ pkgs, lib, ... }:

let
  mkContainer = import ./mkContainer.nix { inherit lib; };
in
mkContainer {
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
