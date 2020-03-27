{ config, pkgs, lib, ... }:

with lib;

let
  # TODO: move this to an iPs.nix file
  extMAC = "00:25:90:d8:e5:1a";
  extInterface = "eth0";

  ext4IP = "148.251.50.190";
  ext4Gateway = "148.251.50.161";
  ext4Netmask = "255.255.255.224";
  ext4PrefixLength = 32;

  ext6IP = "2a01:4f8:202:1097::1";
  ext6Gateway = "fe80::1";
  ext6PrefixLength = 64;
in {
  networking.hostName = "duck";
  networking.domain = "srv.lama-corp.space";

  networking.nameservers = [
    "1.1.1.1" "1.0.0.1" "208.67.222.222"
    "2606:4700:4700::1111" "2606:4700:4700::1001" "2620:119:35::35"
  ];

  boot.kernelParams = [
    "ip=${ext4IP}::${ext4Gateway}:${ext4Netmask}:duckboot::none"
  ];

  services.udev.extraRules = ''SUBSYSTEM=="net", ATTR{address}=="${extMAC}", NAME="${extInterface}"'';

  networking.useDHCP = false;

  networking.bridges."br0" = {
    interfaces = [ ];
    rstp = false;
  };

  networking.interfaces."${extInterface}" = {
    ipv4.addresses = [
      { address = ext4IP; prefixLength = ext4PrefixLength; }
    ];
    ipv6.addresses = [
      { address = ext6IP; prefixLength = 128; }
    ];
  };

  networking.interfaces."br0" = {
    ipv4.addresses = [
      { address = ext4IP; prefixLength = ext4PrefixLength; }
    ];
    ipv6.addresses = [
      { address = ext6IP; prefixLength = ext6PrefixLength; }
    ];
    ipv4.routes = [
      { address = "148.251.148.232"; prefixLength = 32; }
      { address = "148.251.148.233"; prefixLength = 32; }
      { address = "148.251.148.234"; prefixLength = 32; }
      { address = "148.251.148.235"; prefixLength = 32; }
      { address = "148.251.148.236"; prefixLength = 32; }
      { address = "148.251.148.237"; prefixLength = 32; }
      { address = "148.251.148.238"; prefixLength = 32; }
      { address = "148.251.148.239"; prefixLength = 32; }
    ];
  };

  # See https://www.sysorchestra.com/hetzner-root-server-with-kvm-ipv4-and-ipv6-networking/
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.eth0.send_redirects" = false;
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking.defaultGateway = {
    address = ext4Gateway;
    interface = extInterface;
  };
  networking.defaultGateway6 ={
    address = ext6Gateway;
    interface = extInterface;
  };

  networking.nat = {
    enable = config.networking.wireguard.enable;
    externalInterface = extInterface;
    internalInterfaces = [ "wg0" ];
  };

  networking.wireguard = {
    interfaces = {
      "wg0" = {
        ips = [ "10.100.1.1/16" ];
        listenPort = 51820;

        peers = [
          { # hedgehog
            publicKey = "qBFik9hW+zN6gbT4InmhIomtV3CtJsYaRZuuEVng2Xo=";
            allowedIPs = [ "10.100.6.1/32" ];
          }
        ];
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowPing = true;

    allowedTCPPorts = [ 22 25 80 443 587 993 ];
    allowedUDPPorts = [ ] ++ (optionals config.networking.wireguard.enable (singleton 51820)); # Wireguard

    allowedTCPPortRanges = [
      { from = 8000; to = 8100; } # weechat
    ];
    allowedUDPPortRanges = [
      { from = 60000; to = 61000; } # mosh
    ];

    extraCommands = ''
      iptables -t nat -A POSTROUTING -s 10.100.0.0/16 -o eth0 -j MASQUERADE
    '';
  };
}
