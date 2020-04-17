{ config, pkgs, lib, ... }:

with lib;

let
  dotshabka = import <dotshabka> {};
in with dotshabka.data.iPs.space.lama-corp; {
  imports = [
    ./dns.nix
  ];

  boot.kernelParams = with fsn.srv.duck; [
    "ip=${external.v4.ip}::${external.v4.gw}:255.255.255.224:duckboot::none"
  ];

  services.udev.extraRules = with fsn.srv.duck; ''
    SUBSYSTEM=="net", ATTR{address}=="${external.mac}", NAME="${external.interface}"
  '';

  # See https://www.sysorchestra.com/hetzner-root-server-with-kvm-ipv4-and-ipv6-networking/
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.eth0.send_redirects" = false;
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking = with fsn.srv.duck; {

    hostName = "duck";
    domain = "srv.fsn.lama-corp.space";

    nameservers = [ "127.0.0.1" "::1" ];

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
      enable = true;
      interfaces = {
        "${wg.interface}" = {
          ips = [ "${wg.v4.ip}/${toString wg.v4.prefixLength}" ];
          listenPort = 51820;
          privateKeyFile = "/srv/secrets/root/wireguard.key";

          peers = [
            { # hub.virt.duck.srv.fsn.lama-corp.space
              publicKey = "xa3HxQyrwM+uR8/NqiOCzonwOCqSD/ghkFow4d1omkQ=";
              allowedIPs = [ "${fsn.srv.duck.virt.hub.wg.v4.ip}/32" ];
            }
            { # nas.srv.bar.lama-corp.space
              publicKey = "4Iwgsv3cQdWfbym0ZZz71QUiVO/vmt3psTBgue+j/U4=";
              allowedIPs = [ "${bar.srv.nas.wg.v4.ip}/32" "192.168.44.0/24" ];
            }
            { # hedgehog.lap.fly.lama-corp.space
              publicKey = "qBFik9hW+zN6gbT4InmhIomtV3CtJsYaRZuuEVng2Xo=";
              allowedIPs = [ "${fly.lap.hedgehog.wg.v4.ip}/32" ];
            }
            { # trunck.lap.fly.lama-corp.space
              publicKey = "5AKJzXk/ybUl4fQXsP4aycHBbFP+IhhWbFUVtJCUzg0=";
              allowedIPs = [ "${fly.lap.trunck.wg.v4.ip}/32" ];
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
            53 # DNS
            19999 # Netdata
          ];
          allowedUDPPorts = [
            53 # DNS
          ];

          allowedTCPPortRanges = [ ];
          allowedUDPPortRanges = [ ];
        };
      };
    };
  };
}
