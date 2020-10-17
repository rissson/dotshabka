{ ... }:

{
  containers.devoups-1 = {
    autoStart = true;
    bindMounts."persist" = {
      hostPath = "/srv/containers/devoups-1/persist/";
      mountPoint = "/persist";
      isReadOnly = false;
    };
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.231.0.1";
    localAddress = "10.231.0.5";

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
  systemd.services."container@devoups-1".environment.SYSTEMD_NSPAWN_USE_CGNS = "0";
}
