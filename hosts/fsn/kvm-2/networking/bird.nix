{ ... }:

{
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 179 ];
  networking.firewall.interfaces.wg212270.allowedTCPPorts = [ 179 ];
  networking.firewall.interfaces.br-k8s.allowedTCPPorts = [ 179 ];

  services.bird2 = {
    enable = true;
    config = ''
      router id 168.119.71.47;

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

        route 2001:db8:dead::/48 via "br-vms";
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
        #error wait time 30, 60;
        error wait time 1, 2;

        ipv4 {
          import none;
          export none;
        };

        ipv6 {
          import none;
          export where source = RTS_STATIC;
        };
      }


      template bgp bgp_k8s {
        interface "br-k8s";
        local as 67254;
        error wait time 1, 2;

        ipv4 {
          import all;
          export none;
        };

        ipv6 {
          import none;
          export none;
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

      protocol bgp 'master-11.k8s.fsn' from bgp_k8s {
        neighbor 172.28.7.11 as 67111;
      }

      protocol bgp 'master-12.k8s.fsn' from bgp_k8s {
        neighbor 172.28.7.12 as 67111;
      }

      protocol bgp 'master-13.k8s.fsn' from bgp_k8s {
        neighbor 172.28.7.13 as 67111;
      }

      protocol bgp 'worker-11.k8s.fsn' from bgp_k8s {
        neighbor 172.28.7.111 as 67111;
      }

      protocol bgp 'worker-12.k8s.fsn' from bgp_k8s {
        neighbor 172.28.7.112 as 67111;
      }

      protocol bgp 'worker-13.k8s.fsn' from bgp_k8s {
        neighbor 172.28.7.113 as 67111;
      }
    '';
  };
}
