# I only have one router at home, which triples as a
# firewall and DNS server with dynamic DNS support.
# This profile is very coupled to that machine's role
# and interface names.

{ config, pkgs, lib, ... }:

{
  # Enable routing in the kernel
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;

    # By default, not automatically configure any IPv6 addresses.
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.all.use_tempaddr" = 0;

    # TODO: On WAN, allow IPv6 autoconfiguration and tempory address use.
    #"net.ipv6.conf.${name}.accept_ra" = 2;
    #"net.ipv6.conf.${name}.autoconf" = 1;
  };

  # Disable default firewall stuff
  networking.nat.enable = false;
  networking.firewall.enable = false;

  # Use nftables instead
  networking.nftables = {
    enable = true;
    ruleset =
      ''table ip filter {
  # enable flow offloading for better throughput
  flowtable f {
    hook ingress priority 0;
    devices = { enp1s0, enp2s0 };
  }

  chain output {
    type filter hook output priority 100; policy accept;
  }

  chain input {
    type filter hook input priority filter; policy drop;

    # Allow trusted networks to access the router
    iifname {
      "lo", "enp2s0",
    } counter accept

    tcp dport {ssh} accept

    # Allow returning traffic from enp1s0 and drop everthing else
    iifname "enp1s0" ct state { established, related } counter accept
    iifname "enp1s0" drop
  }

  chain forward {
    type filter hook forward priority filter; policy drop;

    # enable flow offloading for better throughput
    ip protocol { tcp, udp } flow offload @f

    # Allow trusted network WAN access
    iifname {
            "enp2s0",
    } oifname {
            "enp1s0",
    } counter accept comment "Allow trusted LAN to WAN"

    # Allow established WAN to return
    iifname {
            "enp1s0",
    } oifname {
            "enp2s0",
    } ct state established,related counter accept comment "Allow established back to LANs"
  }
}

table ip nat {
  chain prerouting {
    type nat hook output priority filter; policy accept;
  }

  # Setup NAT masquerading on the enp1s0 interface
  chain postrouting {
    type nat hook postrouting priority filter; policy accept;
    oifname "enp1s0" masquerade
  } 
}'';
  };

  # Bundle DNS server
  # To avoid publishing loopback addresses from
  # /etc/hosts, use alt file /etc/dnsmasq_hosts
  services.dnsmasq = {
    enable = true;
    extraConfig = ''
      addn-hosts=/etc/dnsmasq_hosts
      bogus-priv
      dhcp-authoritative
      dhcp-option=option:router,10.1.1.1
      dhcp-range=10.1.1.100,10.1.1.200,24h
      domain=mydomain.test
      domain-needed
      expand-hosts
      interface=enp2s0
      listen-address=::1,127.0.0.1,10.1.1.1
      local=/mydomain.test/
      no-hosts
      no-resolv
      server=8.8.8.8
      server=8.8.4.4
    '';
  };
  environment.etc = {
    dnsmasq_hosts = {
      text = ''
        10.1.1.1 nix-apu nix-apu.mydomain.test
        10.1.1.2 fios fios.mydomain.test
        10.1.1.75 kgpe kgpe.mydomain.test
      '';
      mode = "0777";
    };
  };

  # Hardened SSH for external exposure
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      "127.0.0.0/8"
      "10.1.1.0/8"
    ];
  };

  # OpenNIC DNS sources. Don't forget to add these to dnsmasq config above!
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
}
