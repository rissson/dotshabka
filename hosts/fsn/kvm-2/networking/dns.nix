{ ... }:

{
  lama-corp.services.unbound = {
    enable = true;
    extraData = {
      "mail-1.vrt.fsn" = "172.28.6.11";
      "pine.vrt.fsn" = "172.28.6.201";
      "kvm-2.srv.fsn" = "172.28.6.254";

      "master-11.k8s.fsn" = "172.28.7.11";
      "master-12.k8s.fsn" = "172.28.7.12";
      "master-13.k8s.fsn" = "172.28.7.13";
      "kvm-2.k8s.fsn" = "172.28.7.254";

      # k8s
      "ingress.k8s.fsn" = "172.28.8.10";
      "ldap.k8s.fsn" = "172.28.8.11";
    };
  };
}
