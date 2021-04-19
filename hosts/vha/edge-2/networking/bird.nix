{ ... }:

{
  networking.firewall.allowedTCPPorts = [ 179 ];
  # Protocol 89 is OSPF
  networking.firewall.extraCommands = ''
    iptables -A INPUT -p 89 -j ACCEPT
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D INPUT -p 89 -j ACCEPT
  '';

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

      protocol kernel KERNEL4 {
        merge paths on;
        persist; # Don't remove routes on BIRD shutdown

        ipv4 {
          import none;
          export all;
        };
      }

      protocol kernel KERNEL6 {
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

      protocol static local4 {
        ipv4 {};

        route 172.28.5.0/24 via "lo";
      }

      protocol ospf v2 internal4 {
        graceful restart on;

        ipv4 {
          import all;
          export where proto = "internal4";
        };

        area 0 {
          interface "lo" {
            stub;
          };
          interface "wg0" {
            type nonbroadcast;
            strict nonbroadcast no;
            neighbors {
              172.28.254.4 eligible;
              172.28.254.6 eligible;
            };
          };
        };
      }
    '';
  };
}
