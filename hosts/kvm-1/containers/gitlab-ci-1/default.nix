{ ... }:

{
  containers.gitlab-ci-1 = with import <dotshabka/data/space.lama-corp/fsn> { }; {
    autoStart = true;
    bindMounts."persist" = {
      hostPath = "/srv/containers/gitlab-ci-1/persist/";
      mountPoint = "/persist";
      isReadOnly = false;
    };
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.231.0.1";
    localAddress = "10.231.0.12";

    # Needed for docker
    additionalCapabilities = [ "all" ];
    extraFlags = [
      "--system-call-filter=add_key"
      "--system-call-filter=keyctl"
    ];
    bindMounts."cgroup" = {
      hostPath = "/sys/fs/cgroup";
      mountPoint = "/sys/fs/cgroup";
      isReadOnly = false;
    };

    config = { ... }: ({
      imports = [
        ./configuration.nix
      ];
    } // {
      environment.etc."resolv.conf".text = ''
        nameserver 10.231.0.1
      '';
    });
  };

  # Needed for docker
  systemd.services."container@gitlab-ci-1".environment.SYSTEMD_NSPAWN_USE_CGNS = "0";
}
