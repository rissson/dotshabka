{ pkgs, ... }:

{
  networking = {
    firewall = {
      checkReversePath = false;
    };

    bridges.loopback.interfaces = [ ];
    interfaces = {
      loopback = {
        ipv4.addresses = [{
          address = "172.28.254.2"; # nas-1.bar
          prefixLength = 32;
        }];
        ipv6.addresses = [{
          address = "2001:67c:17fc:ffff::2"; # nas-1.bar
          prefixLength = 128;
        }];
      };
    };
  };

  services.bird2 = {
    enable = true;
    config = ''
      router id 172.28.254.2;

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

          interface "bond0" {
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

          interface "bond0" {
            stub;
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
      ExecStart = "${pkgs.bird-lg-go-proxy}/bin/proxy";
      ProtectSystem = "full";
      ProtectHome = "yes";
      MemoryDenyWriteExecute = "yes";
      User = "bird2";
      Group = "bird2";
    };
  };
}
