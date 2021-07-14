# A declarative container suite goes beyond a profile by
# including a small amount of host configuration along with
# the regular configuration inside the container.

{ pkgs, lib, ... }:

{
  deluge = import ./deluge.nix { inherit pkgs lib; };
  jellyfin = import ./jellyfin.nix { inherit pkgs lib; };
  nextcloud = import ./nextcloud.nix { inherit pkgs lib; };
  samba = import ./samba.nix { inherit pkgs lib; };
  sourcehut = import ./sourcehut.nix { inherit pkgs lib; };
}
