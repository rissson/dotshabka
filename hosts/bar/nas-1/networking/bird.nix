{ ... }:

{
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 179 ];

  services.bird2 = {
    enable = true;
    config = ''
      router id 172.28.254.2;

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

        route 172.28.2.0/24 via "bond0";
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
        if net ~ [ 172.28.2.0/24 ] then {
          accept;
        }
        reject;
      }

      template bgp bgp_tpl {
        interface "wg0";
        local as 65002;
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

      protocol bgp 'kvm-2.srv.fsn' from bgp_tpl {
        neighbor 172.28.254.6 as 65006;
      }

      protocol bgp 'hedgehog.lap.rsn' from bgp_tpl {
        neighbor 172.28.254.101 as 65101;
      }
    '';
  };
}
