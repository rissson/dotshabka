{ config, pkgs, lib, ... }:

with lib;

let
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

  networking.nameservers = [
    "1.1.1.1" "1.0.0.1" "208.67.222.222"
    "2606:4700:4700::1111" "2606:4700:4700::1001" "2620:119:35::35"
  ];

  boot.kernelParams = [
    "ip=${ext4IP}::${ext4Gateway}:${ext4Netmask}:duckboot::none"
  ];

  services.udev.extraRules = ''SUBSYSTEM=="net", ATTR{address}=="${extMAC}", NAME="${extInterface}"'';

  networking.useDHCP = false;
  networking.interfaces."${extInterface}" = {
    ipv4.addresses = [
      { address = ext4IP; prefixLength = ext4PrefixLength; }
    ];
    ipv6.addresses = [
      { address = ext6IP; prefixLength = ext6PrefixLength; }
    ];
  };
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
