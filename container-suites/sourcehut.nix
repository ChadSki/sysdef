{ pkgs, lib, ... }:

let
  mkContainer = import ./mkContainer.nix { inherit lib; };
in
mkContainer {
  guestConfig = {
    services = {
      sourcehut = {
        enable = true;
      };
    };
  };

  hostConfig = { };
}
