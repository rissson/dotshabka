{ pkgs, ... }:

{
  networking = {
    firewall = {
      checkReversePath = false;
      interfaces.br-k8s.allowedTCPPorts = [ 179 ];
    };

    bridges.loopback.interfaces = [ ];
    interfaces = {
      loopback = {
        ipv4.addresses = [{
          address = "172.28.254.6"; # kvm-2.fsn
          prefixLength = 32;
        }];
        ipv6.addresses = [{
          address = "2001:67c:17fc:ffff::6"; # kvm-2.fsn
          prefixLength = 128;
        }];
      };
    };
  };

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


      ### Internal

      protocol ospf v3 ospf4 {
        graceful restart on;

        ipv4 {
          import all;
          export where net ~ 172.28.8.0/24;
        };

        area 0 {
          interface "loopback" {
            stub;
          };

          interface "wg-*" {
            type pointopoint;
          };

          interface "br-vms" {
            stub;
          };
          interface "br-k8s" {
            stub;
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

  systemd.services.bird-lg-go = {
    description = "BIRD looking glass frontend.";
    wantedBy = [ "multi-user.target" ];
    environment = {
      BIRDLG_SERVERS = "edge-1.pvl<172.28.254.4>,edge-2.avh<172.28.254.5>,kvm-2.fsn<172.28.254.6>,nas-1.bar<172.28.254.2>";
      BIRDLG_DOMAIN = "";
      BIRDLG_TITLE_BRAND = "Lama Corp. LG";
      BIRDLG_NAVBAR_BRAND = "Lama Corp. LG";
    };
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      ExecStart = "${pkgs.bird-lg-go-frontend}/bin/frontend";
      ProtectSystem = "full";
      ProtectHome = "yes";
      MemoryDenyWriteExecute = "yes";
    };
  };

  systemd.services.bird-lg-go-proxy = {
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
      ExecStart = "${pkgs.bird-lg-go-proxy}/bin/proxy";
      ProtectSystem = "full";
      ProtectHome = "yes";
      MemoryDenyWriteExecute = "yes";
      User = "bird2";
      Group = "bird2";
    };
  };
}
