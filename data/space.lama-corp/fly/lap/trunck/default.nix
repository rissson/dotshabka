{ ... }:

{
  wg = {
    interface = "wg0";
    publicKey = "5AKJzXk/ybUl4fQXsP4aycHBbFP+IhhWbFUVtJCUzg0=";
    v4 = {
      subnet = "172.28.102.0";
      ip = "172.28.102.1";
      prefixLength = 24;
    };
    v6 = {
      subnet = "fd00:7fd7:e9a5:102::";
      ip = "fd00:7fd7:e9a5:102::1";
      prefixLength = 64;
    };
  };
}
