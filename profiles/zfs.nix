{ config, pkgs, lib, ... }:

{
  boot.supportedFilesystems = [ "zfs" ]; # grub
  boot.initrd.supportedFilesystems = [ "zfs" ]; # initramfs

  # Erase root on boot
  # boot.initrd.postDeviceCommands = lib.mkAfter ''
  #  zfs rollback -r rpool/local/root@blank
  # '';

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    trim.enable = true;
  };
}