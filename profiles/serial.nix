{ config, pkgs, lib, ... }:

{
  # Assuming we're using grub... what would the systemd-boot option be?
  boot.loader.grub.extraConfig = "
    serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
    terminal_input serial
    terminal_output serial
  ";

  boot.kernelParams = [ "console=ttyS0,115200n8" ];
}
