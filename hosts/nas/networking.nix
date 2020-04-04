{ config, pkgs, lib, ... }:

with lib;

{
  networking.hostName = "nas"; # Define your hostname.
  networking.domain = "srv.bar.lama-corp.space";
  networking.hostId = "3474d85a";

  networking.nameservers = [
    "1.1.1.1" "1.0.0.1" "208.67.222.222"
    "2606:4700:4700::1111" "2606:4700:4700::1001" "2620:119:35::35"
  ];

  networking.useDHCP = false;
  networking.interfaces."bond0" = {
    ipv4.addresses = [
      { address = "192.168.44.253"; prefixLength = 24; }
    ];
  };

  networking.defaultGateway = {
    address = "192.168.44.254";
    interface = "bond0";
  };

  networking.bonds."bond0" = {
    interfaces = [ "enp3s0" "enp4s0" ];
    driverOptions = {
      mode = "balance-alb";
    };
  };

  networking.firewall = {
    enable = true;
    allowPing = true;

    allowedTCPPorts = [
      22 # SSH
      53 # DNS
      67 # DHCP
      19999 # Netdata
    ];
    allowedUDPPorts = [
      53 # DNS
      67 # DHCP
    ] ++ (optionals config.networking.wireguard.enable (singleton 51820)); # Wireguard

    allowedTCPPortRanges = [ ];
    allowedUDPPortRanges = [
      { from = 60000; to = 61000; } # mosh
    ];
  };
}
