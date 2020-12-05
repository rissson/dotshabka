{ ... }:

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
    ];
  };
}
