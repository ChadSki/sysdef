{ config, lib, pkgs, ... }:

{
  home.username = "chad";
  home.homeDirectory = "/home/chad";
  home.stateVersion = "21.05";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # Basics
    binutils
    coreutils
    curl
    fd
    file
    git
    htop
    ripgrep
    screen
    tmux
    tree
    vim
    wget
    whois

    # Fancies
    bat
    bottom
    direnv
    dosfstools
    glances
    gptfdisk
    jq
    nix-index
    nixpkgs-fmt
    parallel
    pciutils
    skim
    tealdeer
    usbutils
    utillinux

    # Network utilities
    dnsutils # dig, nslookup, etc (bind alias)
    iputils
    nmap # scanning
    ethtool # manage NIC settings (offload, NIC feeatures, ...)
    tcpdump # view network traffic
    conntrack-tools # view network connection states
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Fish shell
  programs.fish.enable = true;
}
