{ config, ... }:

{
  imports = [
    ./monitoring
  ];

  containers.reverse-2 = with import <dotshabka/data/space.lama-corp/fsn> { }; {
    autoStart = true;
    bindMounts."persist" = {
      hostPath = "/srv/containers/reverse-2/persist/";
      mountPoint = "/persist";
      isReadOnly = false;
    };
    bindMounts."root" = {
      hostPath = "/srv/containers/reverse-2/root/";
      mountPoint = "/root";
      isReadOnly = false;
    };
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "br-public";
    localAddress = with vrt.reverse-2.external.v4; "${ip}/${toString prefixLength}";
    localAddress6 = with vrt.reverse-2.external.v6; "${ip}/${toString prefixLength}";

    extraVeths = {
      "${vrt.reverse-2.internal.interface}" = {
        hostBridge = "br-local";
        localAddress = with vrt.reverse-2.internal.v4; "${ip}/${toString prefixLength}";
      };
    };

    config = { ... }: ({
      imports = [
        ./configuration.nix
      ];
    } // {
      environment.etc."resolv.conf".text = ''
        nameserver ${srv.kvm-1.internal.v4.ip}
      '';
      networking.extraHosts = config.networking.extraHosts;
      networking.defaultGateway = {
        address = vrt.reverse-2.external.v4.gw;
        interface = vrt.reverse-2.external.interface;
      };
      networking.defaultGateway6 = {
        address = vrt.reverse-2.external.v6.gw;
        interface = vrt.reverse-2.external.interface;
      };
    });
  };
}
