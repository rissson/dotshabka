{ config, pkgs, lib, ... }:

with lib;

with import <dotshabka/data/space.lama-corp> { }; with fsn.srv.duck; {
  imports = [
    ./dns.nix
  ];

  boot.kernelParams = [
    "ip=${external.v4.ip}::${external.v4.gw}:255.255.255.224:duckboot::none"
  ];

  # See https://www.sysorchestra.com/hetzner-root-server-with-kvm-ipv4-and-ipv6-networking/
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.eno1.send_redirects" = false;
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking = {

    hostName = "duck";
    domain = "srv.fsn.lama-corp.space";

    nameservers = with import <dotshabka/data> {}; [
      "127.0.0.1"
      "::1"
    ] ++ externalNameservers;

    useDHCP = false;

    bridges = {
      "${external.bridge}" = {
        interfaces = [ ];
        rstp = false;
      };
      "${internal.interface}" = {
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

      "${external.bridge}" = {
        ipv4.addresses = [
          { address = external.v4.ip; prefixLength = external.v4.prefixLength; }
        ];
        ipv6.addresses = [
          { address = external.v6.ip; prefixLength = external.v6.prefixLength; }
        ];
        ipv4.routes = [
          { address = virt.hub.external.v4.ip; prefixLength = virt.hub.external.v4.prefixLength; }
          { address = virt.lewdax.external.v4.ip; prefixLength = virt.lewdax.external.v4.prefixLength; }
          { address = mail-1.external.v4.ip; prefixLength = mail-1.external.v4.prefixLength; }
        ];
      };

      "${internal.interface}" = {
        ipv4.addresses = [
          { address = internal.v4.ip; prefixLength = internal.v4.prefixLength; }
        ];
        ipv6.addresses = [
          { address = internal.v6.ip; prefixLength = internal.v6.prefixLength; }
        ];
        proxyARP = true; # CRITICAL TO ACCESS THE WIREGUARD
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
      internalInterfaces = [ internal.interface wg.interface ];
    };

    wireguard = {
      enable = true;
      interfaces = with wg; {
        "${interface}" = {
          ips = [
            "${v4.ip}/32"
            "${v6.ip}/128"
          ];
          listenPort = 51820;
          privateKeyFile = "/srv/secrets/root/wireguard.key";

          peers = [
            {
              # nas.srv.bar
              inherit (bar.srv.nas.wg) publicKey;
              allowedIPs = with bar.srv.nas.wg; [
                # Wireguard networks
                "${v4.subnet}/${toString v4.prefixLength}"
                "${v6.subnet}/${toString v6.prefixLength}"
                # Local networks
                bar.subnet
              ];
            }
            {
              # giraffe.srv.nbg
              inherit (nbg.srv.giraffe.wg) publicKey;
              allowedIPs = with nbg.srv.giraffe.wg; [
                "${v4.subnet}/${toString v4.prefixLength}"
                "${v6.subnet}/${toString v6.prefixLength}"
              ];
              endpoint = "${nbg.srv.giraffe.external.v4.ip}:51820";
            }
            {
              # hedgehog.lap.fly
              inherit (fly.lap.hedgehog.wg) publicKey;
              allowedIPs = with fly.lap.hedgehog.wg; [
                "${v4.subnet}/${toString v4.prefixLength}"
                "${v6.subnet}/${toString v6.prefixLength}"
              ];
            }
            {
              # trunck.lap.fly
              inherit (fly.lap.trunck.wg) publicKey;
              allowedIPs = with fly.lap.trunck.wg; [
                "${v4.subnet}/${toString v4.prefixLength}"
                "${v6.subnet}/${toString v6.prefixLength}"
              ];
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
      allowedUDPPorts = [
        51820 # Wireguard
      ];

      allowedTCPPortRanges = [
        { from = 8000; to = 8100; } # weechat
        { from = 6881; to = 6999; } # aria2c
      ];
      allowedUDPPortRanges = [
        { from = 60000; to = 61000; } # mosh
        { from = 6881; to = 6999; } # aria2c
      ];

      interfaces = {
        "${internal.interface}" = {
          allowedTCPPorts = [
            53 # DNS
          ];
          allowedUDPPorts = [
            53 # DNS
          ];

          allowedTCPPortRanges = [ ];
          allowedUDPPortRanges = [ ];
        };
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
