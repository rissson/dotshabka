{ soxincfg, lib, pkgs, ... }:

{
  imports = [
    soxincfg.nixosModules.profiles.server
    soxincfg.nixosModules.profiles.kvm-2-vm
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.ens3.send_redirects" = false;
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv4.ip_nonlocal_bind" = true;
    "net.ipv4.conf.lxc*.rp_filter" = 0;
  };

  environment.persistence."/persist" = {
    directories = [
      "/etc/rancher"
      "/var/lib/docker"
      "/var/lib/dockershim"
      "/var/lib/kubelet"
      "/var/lib/rancher"
    ];
  };

  networking = {
    hostName = "k3s-1";
    domain = "k3s-1.fsn.lama.tel";
    nameservers = [ "172.28.7.254" ];

    useDHCP = false;
    dhcpcd.enable = false;

    interfaces = {
      ens3 = {
        ipv4.addresses = [{
          address = "172.28.7.1";
          prefixLength = 24;
        }];
      };
    };

    defaultGateway = {
      address = "172.28.7.254";
      interface = "ens3";
    };

    firewall.enable = false;
  };

  boot.supportedFilesystems = [ "nfs" ];

  services.k3s = {
    enable = true;
    docker = true;
    role = "server";
    disableAgent = false;
    extraFlags = lib.concatStringsSep " \\\n " [
      "--tls-san apiserver.fsn.lama.tel"
      "--disable-network-policy"
      "--flannel-backend=none"
      "--disable local-storage"
      "--disable servicelb"
      "--disable traefik"
    ];
  };

  environment.systemPackages = [ pkgs.kubectl pkgs.iptables ];
  environment.variables.KUBECONFIG = "/var/lib/rancher/k3s/server/cred/admin.kubeconfig";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.05"; # Did you read the comment?
}
