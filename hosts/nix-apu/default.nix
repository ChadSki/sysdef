# PCEngines APU2
{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../profiles/common.nix
      ../../profiles/router.nix # the important role
      ../../profiles/serial.nix
      ../../profiles/zfs.nix
    ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  networking.hostName = "nix-apu";
  networking.hostId = "8C62C0DA"; # ZFS requirement; TODO: can this be derived somehow? 

  # traditional WAN eth0, LAN eth1
  networking.interfaces = {
    # WAN
    enp1s0.useDHCP = true;

    # LAN
    enp2s0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "10.1.1.1";
        prefixLength = 24;
      }];
    };

    # unused for now
    enp3s0.useDHCP = false;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

