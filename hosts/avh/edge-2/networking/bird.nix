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
          address = "172.28.254.5"; # edge-2.avh
          prefixLength = 32;
        }];
        ipv4.routes = [{
          address = "172.28.5.0";
          prefixLength = 24;
        }];
        ipv6.addresses = [{
          address = "2001:67c:17fc:ffff::5"; # edge-2.avh
          prefixLength = 128;
        }];
      };
    };
  };

  services.bird2 = {
    enable = true;
    config = ''
      router id 172.28.254.5;

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

      protocol static vmhaus_neighbor {
        ipv6 {};
        route 2402:28c0:3::179/128 via fe80::1 %ens3;
      }

      filter reject_vmhaus_neighbor {
        if net = 2001:19f0:ffff::1/128 then {
          reject;
        }
        accept;
      }

      protocol bgp vmhaus {
        local as 212024;
        source address 2a00:1098:2e:2::1;

        error wait time 30, 60;
        graceful restart on;

        multihop 2;

        ipv4 {
          import none;
          export none;
        };

        ipv6 {
          import filter reject_vmhaus_neighbor;
          export where proto = "AS212024";
        };

        neighbor 2402:28c0:3::179 as 136620;
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
