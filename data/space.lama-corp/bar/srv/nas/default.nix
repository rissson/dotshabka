{ ... }:

{
  internal = {
    mac = "8e:3d:9b:ab:c9:c5";
    bondInterfaces = [ "enp3s0" "enp4s0" ];
    interface = "bond0";
    v4 = {
      ip = "192.168.44.253";
      prefixLength = 24;
      gw = "192.168.44.254";
    };
  };
  wg = {
    interface = "wg0";
    publicKey = "+nasSLlJuvgViVcmcCcjMFvwRLmYgGRkBed+Z6qxfw4=";
    v4 = {
      subnet = "172.28.2.0";
      ip = "172.28.2.1";
      prefixLength = 24;
    };
    v6 = {
      subnet = "fd00:7fd7:e9a5:2::";
      ip = "fd00:7fd7:e9a5:2::1";
      prefixLength = 64;
    };
  };
}
