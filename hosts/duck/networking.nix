{ config, pkgs, lib, ... }:

with lib;

let
  extMAC = "50:46:5d:4d:23:5c";
  extInterface = "eth0";

  ext4IP = "213.239.217.59";
  ext4Gateway = "213.239.217.33";
  ext4Netmask = "255.255.255.224";
  ext4PrefixLength = 27;

  ext6Gateway = "";
in {
  networking.hostName = "duck";
  networking.hostId = "bc7c6bda";

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
  };
  networking.defaultGateway = ext4Gateway;

  networking.firewall = {
    enable = true;
    allowPing = true;

    allowedTCPPorts = [ 22 80 443 ];
    allowedUDPPorts = [ ];

    allowedTCPPortRanges = [
      { from = 8001; to = 8002; } # weechat
    ];
    allowedUDPPortRanges = [
      { from = 60000; to = 61000; } # mosh
    ];
  };
}
