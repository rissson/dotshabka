{ ... }:

{
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 179 ];
  networking.firewall.interfaces.br-k8s.allowedTCPPorts = [ 179 ];

  services.bird2 = {
    enable = true;
    config = ''
      router id 172.28.254.6;

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

        route 172.28.6.0/24 via "br-vms";
        route 172.28.7.0/24 via "br-k8s";
      }

      protocol static STATIC6 {
        ipv6 {
          preference 110;
        };
      }

      filter accept_all {
        accept;
      }

      filter reject_all {
        reject;
      }

      filter export_subnets {
        if net ~ [ 172.28.6.0/24, 172.28.7.0/24, 172.28.8.10/32, 172.28.8.11/32 ] then {
          accept;
        }
        reject;
      }

      template bgp bgp_tpl {
        interface "wg0";
        local as 65006;
        error wait time 30, 60;

        ipv4 {
          import filter accept_all;
          export filter export_subnets;
        };

        ipv6 {
          import none;
          export none;
        };
      }

      protocol bgp 'nas.srv.bar' from bgp_tpl {
        neighbor 172.28.254.2 as 65002;
      }

      protocol bgp 'hedgehog.lap.rsn' from bgp_tpl {
        neighbor 172.28.254.101 as 65101;
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
