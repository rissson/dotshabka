{ config, pkgs, lib, ... }:

with lib;

let

  dotshabka = import ../.. { };

in {
  boot.kernelParams = with dotshabka.data.iPs.space.lama-corp.fsn.srv.duck; [
    "ip=${external.v4.ip}::${external.v4.gw}:255.255.255.224:duckboot::none"
  ];

  services.udev.extraRules = with dotshabka.data.iPs.space.lama-corp.fsn.srv.duck; ''
    SUBSYSTEM=="net", ATTR{address}=="${external.mac}", NAME="${external.interface}"
  '';

  networking = with dotshabka.data.iPs.space.lama-corp.fsn.srv.duck; {

    hostName = "duck";
    domain = "srv.fsn.lama-corp.space";

    nameservers = dotshabka.data.iPs.externalNameservers;

    useDHCP = false;

    bridges = {
      "br0" = {
        interfaces = [ ];
        rstp = false;
      };
    };

    interfaces = {
      "${external.interface}" = {
        ipv4.addresses = [
          { address = external.v4.ip; prefixLength = external.v4.prefixLength; }
        ];
        ipv6.addresses = [
          { address = external.v6.ip;  prefixLength = 128; }
        ];
      };

      "br0" = {
        ipv4.addresses = [
          { address = external.v4.ip; prefixLength = external.v4.prefixLength; }
        ];
        ipv6.addresses = [
          { address = external.v6.ip; prefixLength = external.v6.prefixLength; }
        ];
        ipv4.routes = with virt; [
          { address = hub.external.v4.ip; prefixLength = hub.external.v4.prefixLength; }
          { address = lewdax.external.v4.ip; prefixLength = lewdax.external.v4.prefixLength; }
        ];
      };
    };

    defaultGateway = {
      address = external.v4.gw;
      interface = external.interface;
    };
    defaultGateway6 = {
      address = external.v6.gw;
      interface = external.interface;
    };

    nat = {
      enable = config.networking.wireguard.enable;
      externalInterface = external.interface;
      internalInterfaces = [ wg.interface ];
    };

    wireguard = {
      enable = false; # enabled by secrets
      interfaces = {
        "${wg.interface}" = {
          ips = [ "${wg.v4.ip}/${toString wg.v4.prefixLength}" ];
          listenPort = 51820;

          peers = [
            { # nas.srv.bar.lama-corp.space
              publicKey = "4Iwgsv3cQdWfbym0ZZz71QUiVO/vmt3psTBgue+j/U4=";
              allowedIPs = [ "172.28.0.0/${toString wg.v4.prefixLength}" ];
              endpoint = "bar.lama-corp.space:51820"; # Represents the public IP of the bar network
              persistentKeepalive = 25;
            }
            { # hedgehog.lap.fly.lama-corp.space
              publicKey = "qBFik9hW+zN6gbT4InmhIomtV3CtJsYaRZuuEVng2Xo=";
              allowedIPs = [ "172.28.101.1/32" ];
            }
          ];
        };
      };
    };

    firewall = {
      enable = true;
      allowPing = true;

      allowedTCPPorts = [
        22 # SSH
        80 # nginx
        443 # nginx
      ];
      allowedUDPPorts = [ ] ++
        (optionals config.networking.wireguard.enable (singleton 51820)) # Wireguard
      ;

      allowedTCPPortRanges = [
        { from = 8000; to = 8100; } # weechat
        { from = 6881; to = 6999; } # aria2c
      ];
      allowedUDPPortRanges = [
        { from = 60000; to = 61000; } # mosh
        { from = 6881; to = 6999; } # aria2c
      ];

      interfaces = {
        "${wg.interface}" = {
          allowedTCPPorts = [
            19999 # Netdata
          ];
          allowedUDPPorts = [ ];

          allowedTCPPortRanges = [ ];
          allowedUDPPortRanges = [ ];
        };
      };
    };
  };

  # See https://www.sysorchestra.com/hetzner-root-server-with-kvm-ipv4-and-ipv6-networking/
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.eth0.send_redirects" = false;
    "net.ipv6.conf.all.forwarding" = true;
  };
}
