{ ... }:

{
  services.grafana = {
    enable = true;
    addr = "127.0.0.1";
    rootUrl = "https://grafana.lama-corp.space";
    domain = "grafana.lama-corp.space";

    auth.anonymous = {
      enable = true;
      org_name = "Lama Corp.";
    };

    analytics.reporting.enable = false;
  };
}
