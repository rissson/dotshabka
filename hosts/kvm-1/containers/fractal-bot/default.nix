{ ... }:

{
  containers.fractal-bot = {
    autoStart = true;
    bindMounts."persist" = {
      hostPath = "/srv/containers/fractal-bot/persist/";
      mountPoint = "/persist";
      isReadOnly = false;
    };
    bindMounts."root" = {
      hostPath = "/srv/containers/fractal-bot/root/";
      mountPoint = "/root";
      isReadOnly = false;
    };
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.231.0.1";
    localAddress = "10.231.0.2";

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
