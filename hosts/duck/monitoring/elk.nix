{ ... }:

{
  services.elasticsearch = {
    enable = true;
    dataDir = "/srv/elk/elasticsearch";
    cluster_name = "lama-corp";
    extraConf = ''
      node.name: "duck"
      node.master: true
    '';
  };

  services.kibana = {
    enable = true;
    dataDir = "/srv/elk/kibana";
    listenAddress = "172.28.1.1";
  };
}
