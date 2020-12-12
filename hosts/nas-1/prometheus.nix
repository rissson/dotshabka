{ config, ... }:

{
  services.prometheus = {
    enable = true;
    webExternalUrl = "https://prometheus.lama-corp.space/";
    listenAddress = "127.0.0.1";

    scrapeConfigs = [
      {
        job_name = "chaudiered";
        scrape_interval = "30s";
        static_configs = [
          { targets = [ "cuckoo.srv.bar.lama-corp.space:80" ]; }
        ];
      }
      {
        job_name = "netdata-scrape";
        scrape_interval = "15s";
        metrics_path = "/api/v1/allmetrics";
        params = {
          format = [ "prometheus_all_hosts" ];
          source = [ "average" ];
          server = [ config.networking.fqdn ];
        };
        honor_labels = true;
        static_configs = [
          {
            targets = map (host: "${host}.lama-corp.space:19999") [
              "cuckoo.srv.bar"
              "nas-1.srv.bar"

              "kvm-2.srv.fsn"
              "mail-1.vrt.fsn"
              "master-11.k8s.fsn"
              "master-12.k8s.fsn"
              "master-13.k8s.fsn"
              "worker-11.k8s.fsn"
              "worker-12.k8s.fsn"
              "worker-13.k8s.fsn"
            ];
          }
        ];
      }
    ];
  };
}
