# my Asus KGPE-D16 server
{ config, pkgs, lib, ... }:

let
  container-suites = import ../../container-suites { inherit pkgs lib; };
in {
  # Merge these profiles into this machine
  imports =
    [
      ./hardware-configuration.nix
      ../../profiles/common.nix
      ../../profiles/serial.nix
      ../../profiles/zfs.nix
    ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  networking.hostName = "kgpe";
  networking.hostId = "65EFBA84"; # ZFS requirement; TODO: can this be derived somehow?

  # LAN
  networking.nameservers = [ "10.1.1.1" ];

  # Create a bridge interface on the primary ethernet, to support containers using full DHCP.
  # TODO: I would like br0 to use DHCP also but I couldn't get it to work. Static IP for now.
  networking.bridges = { br0 = { interfaces = [ "enp3s0" ]; }; };
  networking.interfaces.br0.ipv4.addresses = [ { address = "10.1.1.75"; prefixLength = 24; } ];
  networking.defaultGateway = { address = "10.1.1.1"; interface = "br0"; };

  # Plain DHCP for the secondary ethernet port
  networking.interfaces.enp4s0.useDHCP = true;

  # Use NetworkManager, but let containers manage themselves
  networking.networkmanager.unmanaged = [ "interface-name:vb-*" ];

  # Default firewall, explicitly open ports for Nextcloud and Samba
  networking.firewall = {
    allowPing = true;
    allowedTCPPorts = [ 445 139 ];
    allowedUDPPorts = [ 137 138 ];
  };

  virtualisation.docker.enable = true;

  # This machine hosts the following web apps
  containers.deluge = container-suites.deluge;
  #containers.jellyfin = container-suites.jellyfin;
  #containers.nextcloud = container-suites.nextcloud;
  containers.samba = container-suites.samba;
  #containers.sourcehut = container-suites.sourcehut;

  #boot.binfmt.emulatedSystems = [ "powerpc64le-linux" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

