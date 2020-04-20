{ ... }:

{
  services.elasticsearch = {
    enable = true;
    dataDir = "/srv/elasticsearch";
    extraConf = ''
      node.name: "duck"
      node.master: true
    '';
  };
}
