{ ... }:

{
  services.grafana = {
    enable = true;
    addr = "172.28.3.1";
    dataDir = "/srv/grafana";
    rootUrl = "http://172.28.3.1:3000";
  };
}
