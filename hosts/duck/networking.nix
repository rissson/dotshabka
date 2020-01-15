{ config, pkgs, lib, ... }:

with lib;

let
  # TODO: move this to an iPs.nix file
  extMAC = "00:25:90:d8:e5:1a";
  extInterface = "eth0";

  ext4IP = "148.251.50.190";
  ext4Gateway = "148.251.50.161";
  ext4Netmask = "255.255.255.224";
  ext4PrefixLength = 27;

  ext6IP = "2a01:4f8:202:1097::1";
  ext6Gateway = "fe80::1";
  ext6PrefixLength = 64;
in {
  networking.hostName = "duck";
  networking.domain = "lama-corp.space";

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
    interfaces = [ "tap3" ];
  };

  networking.interfaces."${extInterface}" = {
    ipv4.addresses = [
      { address = ext4IP; prefixLength = ext4PrefixLength; }
    ];
    ipv6.addresses = [
      { address = ext6IP; prefixLength = ext6PrefixLength; }
    ];
  };

  networking.interfaces."br0" = {
    ipv4.addresses = [
      { address = "148.251.148.238"; prefixLength = 29; }
    ];
    ipv6.addresses = [
      { address = "2a01:4f8:202:1097::8"; prefixLength = 64; }
    ];
    ipv4.routes = [
      { address = "148.251.148.233"; prefixLength = 32; }
    ];
    ipv6.routes = [
      { address = "2a01:4f8:202:1097::3"; prefixLength = 128; }
    ];
  };

  networking.interfaces."tap3" = {
    # Leaving this here for reference. TODO: move this to an iPs.nix file
    /*ipv4.addresses = [
      { address = "148.251.148.233"; prefixLength = 29; }
    ];
    ipv6.addresses = [
      { address = "2a01:4f8:202:1097::3"; prefixLength = 64; }
    ];*/
    virtual = true;
    virtualType = "tap";
  };

  networking.localCommands = ''
    ip link set tun3 promisc on
  '';

  networking.defaultGateway = {
    address = ext4Gateway;
    interface = extInterface;
  };
  networking.defaultGateway6 ={
    address = ext6Gateway;
    interface = extInterface;
  };

  networking.firewall = {
    enable = true;
    allowPing = true;

    allowedTCPPorts = [ 22 25 80 443 587 993 ];
    allowedUDPPorts = [ ];

    allowedTCPPortRanges = [
      { from = 8000; to = 8100; } # weechat
    ];
    allowedUDPPortRanges = [
      { from = 60000; to = 61000; } # mosh
    ];
  };
}
