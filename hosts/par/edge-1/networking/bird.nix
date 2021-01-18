{ ... }:

{
  networking.firewall.allowedTCPPorts = [ 179 ];

  services.bird2 = {
    enable = true;
    config = ''
      router id 108.61.208.236;

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

      protocol static vultr_neighbor {
        ipv6 {};
        route 2001:19f0:ffff::1/128 via fe80::fc00:3ff:fe21:2eeb %ens3;
      }

      filter reject_vultr_neighbor {
        if net = 2001:19f0:ffff::1/128 then {
          reject;
        }
        accept;
      }

      protocol bgp vultr {
        local as 4288000131;
        source address 2a05:f480:1c00:9ee:5400:03ff:fe21:2eeb;

        error wait time 30, 60;
        graceful restart on;

        multihop 2;

        ipv4 {
          import none;
          export none;
        };

        ipv6 {
          import filter reject_vultr_neighbor;
          export where proto = "AS212024";
        };

        neighbor 2001:19f0:ffff::1 as 64515;
        password "Nrb3hOlXImOMSetW";
      }


      ### Peers

      template bgp peering {
        local as 212024;
        interface "wg-cri";

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

      protocol bgp 'tonkinois.core.vlt.phowork.fr' from peering {
        neighbor fd3c:c1c4:bbff:9a64::cafe as 212270;
        ipv6 {
          # Be careful, those IPs must be allowed in the wireguard
          # configuration
          import where net ~ [ 2a0f:9240:2000::/48, 2a0e:b107:f50::/44 ];
        };
      }

      protocol bgp 'colibri.deliciousmuffins.net' from peering {
        neighbor fd3c:c1c4:bbff:9a64::4251 as 212002;
        ipv6 {
          # Be careful, those IPs must be allowed in the wireguard
          # configuration
          import where net ~ [ 2001:67c:229c::/48, 2a06:3881:7800::/40 ];
        };
      }
    '';
  };
}
