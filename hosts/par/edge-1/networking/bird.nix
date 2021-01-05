{ ... }:

{
  networking.firewall.interfaces.wg212270.allowedTCPPorts = [ 179 ];

  services.bird2 = {
    enable = true;
    config = ''
      router id 108.61.208.236;

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

      protocol static STATIC4 {
        ipv4 {
          preference 110;
        };
      }

      protocol static STATIC6 {
        ipv6 {
          preference 110;
        };

        route 2001:db8:ee1::/48 blackhole;
      }

      filter accept_all {
        accept;
      }

      filter reject_all {
        reject;
      }

      template bgp bgp_cri {
        interface "wg212270";
        local as 65006;
        error wait time 30, 60;

        ipv4 {
          import none;
          export none;
        };

        ipv6 {
          import none;
          export none;
          #export where source = RTS_STATIC;
        };
      }

      protocol bgp 'tonkinois.core.vlt.phowork.fr' from bgp_cri {
        neighbor fd3c:c1c4:bbff:9a64::cafe as 212270;
        ipv6 {
          # Be careful, those IPs must be allowed in the wireguard
          # configuration
          import where net ~ [ 2a0f:9240:2000::/48, 2a0e:b107:f50::/44 ];
        };
      }

      protocol bgp 'colibri.deliciousmuffins.net' from bgp_cri {
        neighbor fd3c:c1c4:bbff:9a64::4251 as 65042;
        ipv6 {
          # Be careful, those IPs must be allowed in the wireguard
          # configuration
          import where net ~ [ 2001:db8:4251::/48 ];
        };
      }
    '';
  };
}
