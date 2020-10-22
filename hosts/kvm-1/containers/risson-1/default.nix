{ ... }:

{
  containers.risson-1 = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.231.0.1";
    localAddress = "10.231.0.10";

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
