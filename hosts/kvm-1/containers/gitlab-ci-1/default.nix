{ ... }:

{
  containers.gitlab-ci-1 = with import <dotshabka/data/space.lama-corp/fsn> { }; {
    autoStart = true;
    bindMounts."persist" = {
      hostPath = "/srv/containers/gitlab-ci-1/persist/";
      mountPoint = "/persist";
      isReadOnly = false;
    };
    bindMounts."root" = {
      hostPath = "/srv/containers/gitlab-ci-1/root/";
      mountPoint = "/root";
      isReadOnly = false;
    };
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "br-local";
    localAddress = with vrt.gitlab-ci-1.internal.v4; "${ip}/${toString prefixLength}";

    config = { ... }: ({
      imports = [
        ./configuration.nix
      ];
    } // {
      environment.etc."resolv.conf".text = ''
        nameserver ${srv.kvm-1.internal.v4.ip}
      '';
      networking.defaultGateway = {
        address = vrt.gitlab-ci-1.internal.v4.gw;
        interface = vrt.gitlab-ci-1.internal.interface;
      };
    });
  };
}
