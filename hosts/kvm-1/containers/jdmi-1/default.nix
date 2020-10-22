{ ... }:

{
  containers.jdmi-1 = {
    autoStart = true;
    bindMounts."persist" = {
      hostPath = "/srv/containers/jdmi-1/persist/";
      mountPoint = "/persist";
      isReadOnly = false;
    };
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.231.0.1";
    localAddress = "10.231.0.8";

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
}
