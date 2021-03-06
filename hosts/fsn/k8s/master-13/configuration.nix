{ soxincfg, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.server
    soxincfg.nixosModules.profiles.kvm-2-vm
    soxincfg.nixosModules.profiles.k8s-node
    soxincfg.nixosModules.profiles.k8s-master
  ];

  networking = {
    hostName = "master-13";
    domain = "k8s.fsn.lama-corp.space";
    nameservers = [ "172.28.7.254" ];

    interfaces.ens3 = {
      ipv4.addresses = [
        {
          address = "172.28.7.13";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = {
      address = "172.28.7.254";
      interface = "ens3";
    };
  };

  services.keepalived.vrrpInstances."VI_01" = {
    unicastPeers = [
      "172.28.7.11"
      "172.28.7.12"
    ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
