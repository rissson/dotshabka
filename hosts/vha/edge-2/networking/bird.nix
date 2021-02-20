{ ... }:

{
  networking.firewall.allowedTCPPorts = [ 179 ];

  services.bird2 = {
    enable = true;
    config = ''
      router id 185.101.96.121;

      timeformat base iso long;
      timeformat log iso long;
      timeformat protocol iso long;
      timeformat route iso long;
      log stderr all;
      debug protocols all;

      protocol device {
      }

      protocol kernel KERNEL4 {
        merge paths on;
        persist; # Don't remove routes on BIRD shutdown

        ipv4 {
          import none;
          export none;
        };
      }

      protocol kernel KERNEL6 {
        merge paths on;
        learn;
        #persist; # Don't remove routes on BIRD shutdown

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


      ### Peers

      template bgp peering {
        local as 212024;
        # interface "FIXME";

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
    '';
  };
}
