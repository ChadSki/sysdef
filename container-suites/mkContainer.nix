# Import-time argument
{ lib, ... }: (

  # Merge some system config into the declarative container guest, and
  # merge some container management details into the host.
  { guestConfig
  , hostConfig
  ,
  }: lib.recursiveUpdate
  {
    # Guest-side
    config = { config, pkgs, ... }: lib.recursiveUpdate
      {
        boot.isContainer = true;
        networking.useDHCP = lib.mkForce true;
        networking.firewall.enable = false;
        environment.systemPackages = [ pkgs.vim ];
        system.stateVersion = "21.05";
      }
      guestConfig;

    # Host-side
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
  }
    hostConfig
)
