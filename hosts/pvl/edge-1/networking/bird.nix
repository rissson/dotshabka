{ inputs, system, pkgs, ... }:

{
  networking = {
    firewall = {
      checkReversePath = false;
      allowedTCPPorts = [ 179 ];
    };

    bridges.loopback.interfaces = [ ];
    interfaces = {
      loopback = {
        ipv4.addresses = [{
          address = "172.28.254.4"; # edge-1.pvl
          prefixLength = 32;
        }];
        ipv4.routes = [{
          address = "172.28.4.0";
          prefixLength = 24;
        }];
        ipv6.addresses = [{
          address = "2001:67c:17fc:ffff::4"; # edge-1.pvl
          prefixLength = 128;
        }];
      };
    };
  };

  services.bird2 = {
    enable = true;
    config = ''
      router id 172.28.254.4;

      timeformat base iso long;
      timeformat log iso long;
      timeformat protocol iso long;
      timeformat route iso long;
      log stderr all;
      debug protocols all;

      protocol device {
      }

      protocol kernel kernel4 {
        merge paths on;
        persist; # Don't remove routes on BIRD shutdown

        ipv4 {
          import none;
          export all;
        };
      }

      protocol kernel kernel6 {
        merge paths on;
        persist; # Don't remove routes on BIRD shutdown

        ipv6 {
          import none;
          export all;
        };
      }


      ### Public routes

      protocol static AS212024 {
        ipv6 {};
        route 2001:67c:17fc::/48 via "lo";
        route 2a06:e881:7700::/40 via "lo";
      }


      ### Filters

      filter accept_all {
        accept;
      }

      filter reject_all {
        reject;
      }


      ### Transit

      protocol static vultr_neighbor {
        ipv6 {};
        route 2001:19f0:ffff::1/128 via fe80::fc00:3ff:fe21:2eeb %ens3;
      }

      protocol bgp vultr {
        local as 212024;
        source address 2a05:f480:1c00:9ee:5400:03ff:fe21:2eeb;

        error wait time 30, 60;
        graceful restart on;

        multihop 2;

        ipv4 {
          import none;
          export none;
        };

        ipv6 {
          import filter {
            if net ~ [ 2001:19f0:ffff::1/128, 2001:67c:17fc::/48, 2a06:e881:7700::/40 ] then {
              reject;
            }
            accept;
          };
          export where proto = "AS212024";
        };

        neighbor 2001:19f0:ffff::1 as 64515;
        password "Hrf4mGfYypgK6yX8";
      }


      ### Peers

      template bgp peering {
        local as 212024;
        interface "wge-cri";

        graceful restart on;
        error wait time 30, 60;

        ipv4 {
          import none;
          export none;
        };

        ipv6 {
          import none;
          export where proto = "AS212024";
        };
      }

      protocol bgp phowork from peering {
        neighbor fd3c:c1c4:bbff:9a64::cafe as 212270;
        ipv6 {
          # Be careful, those IPs must be allowed in the wireguard
          # configuration
          import where net ~ [ 2a0f:9240:2000::/48, 2a0e:b107:f50::/44 ];
        };
      }

      protocol bgp deliciousmuffins from peering {
        neighbor fd3c:c1c4:bbff:9a64::4251 as 212002;
        ipv6 {
          # Be careful, those IPs must be allowed in the wireguard
          # configuration
          import where net ~ [ 2001:67c:229c::/48, 2a06:3881:7800::/40 ];
        };
      }


      ### Internal

      protocol ospf v3 ospf4 {
        graceful restart on;

        ipv4 {
          import all;
          export none;
        };

        area 0 {
          interface "loopback" {
            stub;
          };

          interface "wg-*" {
            type pointopoint;
          };
        };
      }

      protocol ospf v3 ospf6 {
        graceful restart on;

        ipv6 {
          import all;
          export none;
        };

        area 0 {
          interface "loopback" {
            stub;
          };

          interface "wg-*" {
            type pointopoint;
          };
        };
      }
    '';
  };

  systemd.services.bird-lg-go = {
    description = "BIRD looking glass proxy.";
    after = [ "bird2.service" ];
    wants = [ "bird2.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.traceroute ];
    environment = {
      BIRD_SOCKET = "/run/bird.ctl";
    };
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      ExecStart = "${inputs.self.packages.${system}.bird-lg-go-proxy}/bin/proxy";
      ProtectSystem = "full";
      ProtectHome = "yes";
      MemoryDenyWriteExecute = "yes";
      User = "bird2";
      Group = "bird2";
    };
  };
}
