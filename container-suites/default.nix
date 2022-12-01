# A declarative container suite goes beyond a profile by
# including a small amount of host configuration along with
# the regular configuration inside the container.
{
  code-server = import ./code-server.nix;
  deluge = import ./deluge.nix;
  jellyfin = import ./jellyfin.nix;
  nextcloud = import ./nextcloud.nix;
  samba = import ./samba.nix;
  sourcehut = import ./sourcehut.nix;
}
