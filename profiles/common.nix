{ config, pkgs, lib, ... }:

{
  # go-go gadget Nix Flakes!
  nix = {
    gc.automatic = true;
    optimise.automatic = true;
    package = pkgs.nixUnstable;
    settings = {
      auto-optimise-store = true;
      sandbox = true;
      allowed-users = [ "@wheel" ];
      trusted-users = [ "root" "@wheel" ];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      fallback = true
      keep-derivations = true
      keep-outputs = true
      min-free = 536870912
    '';
  };

  # when and where
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # TODO: access controls, fail2ban, etc
  services.openssh.enable = true;


  networking.useDHCP = false; # bad global setting
  networking.dhcpcd = {
    persistent = true;
    # disable IPv6
    extraConfig =
      ''noipv6
noipv6rs'';
  };

  # include me everywhere
  users.users.chad = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };
  security.sudo.extraRules = [{
    groups = [ "wheel" ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];
  programs.fish.enable = true;
  environment.systemPackages = [ pkgs.vim pkgs.git ];
}
