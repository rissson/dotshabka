{ ... }:

{
  lama-corp.services.unbound = {
    enable = true;
    extraData = {
      "master-11.k8s.fsn" = "172.28.7.11";
      "master-12.k8s.fsn" = "172.28.7.12";
      "master-13.k8s.fsn" = "172.28.7.13";
      "worker-11.k8s.fsn" = "172.28.7.111";
      "worker-12.k8s.fsn" = "172.28.7.112";
      "worker-13.k8s.fsn" = "172.28.7.113";
    };
  };
}
