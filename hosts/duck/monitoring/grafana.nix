{ ... }:

{
  services.grafana = {
    enable = true;
    addr = "172.28.1.1";
    dataDir = "/srv/grafana";
    rootUrl = "http://172.28.1.1:3000";
  };
}
