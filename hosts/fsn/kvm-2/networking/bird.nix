{ ... }:

{
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 179 ];
  networking.firewall.interfaces.br-k8s.allowedTCPPorts = [ 179 ];
  networking.firewall.extraCommands = ''
    iptables -A INPUT -p 89 -j ACCEPT
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D INPUT -p 89 -j ACCEPT
  '';

  services.bird2 = {
    enable = true;
    config = ''
      router id 172.28.254.6;

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

      template bgp bgp_k8s {
        interface "br-k8s";
        local as 67254;
        error wait time 1, 2;

        ipv4 {
          import filter {
            if net ~ 172.28.8.0/24 then { accept; }
            if net ~ 148.251.148.234/31 then { accept; }
            reject;
          };
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


      ### Internal

      protocol ospf v2 internal4 {
        graceful restart on;

        ipv4 {
          import all;
          export where net ~ 172.28.8.0/24;
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
              172.28.254.5 eligible;
            };
          };
          interface "br-vms" {
            stub;
          };
          interface "br-k8s" {
            stub;
          };
        };
      }
    '';
  };
}
