{ config, pkgs, lib, ... }:

let
  toYAML = name: attrs: pkgs.runCommandNoCC name {
    preferLocalBuild = true;
    json = builtins.toFile "${name}.json" (builtins.toJSON attrs);
    nativeBuildInputs = [ pkgs.remarshal ];
  } ''json2yaml -i $json -o $out'';

  gatusConfig = {
    metrics = true;
    services = [
      {
        name = "Intranet CRI";
        url = "https://cri.epita.fr";
        interval = "30s";
        conditions = [
          "[STATUS] == 200"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "GitLab";
        url = "https://gitlab.cri.epita.fr";
        interval = "30s";
        conditions = [
          "[STATUS] == 200"
          "[RESPONSE_TIME] <= 500"
        ];
      }
      {
        name = "Mail";
        url = "tcp://mail.cri.epita.fr:587";
        interval = "30s";
        conditions = [
          "[CONNECTED] == true"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "News";
        url = "tcp://news.epita.fr:119";
        interval = "30s";
        conditions = [
          "[CONNECTED] == true"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "DNS";
        url = "tcp://ns-1.cri.epita.fr:53";
        interval = "30s";
        conditions = [
          "[CONNECTED] == true"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "Git";
        url = "tcp://git.cri.epita.fr:22";
        interval = "30s";
        conditions = [
          "[CONNECTED] == true"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "Kerberos KDC ticket server";
        url = "tcp://kerberos-new.pie.cri.epita.fr:88";
        interval = "30s";
        conditions = [
          "[CONNECTED] == true"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "Kerberos KDC kpasswd service";
        url = "tcp://kerberos-new.pie.cri.epita.fr:464";
        interval = "30s";
        conditions = [
          "[CONNECTED] == true"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "Kerberos Admin";
        url = "tcp://kerberos-new.pie.cri.epita.fr:749";
        interval = "30s";
        conditions = [
          "[CONNECTED] == true"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "S3";
        url = "https://s3.cri.epita.fr";
        interval = "30s";
        conditions = [
          "[STATUS] == 200"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "iPXE";
        url = "https://ipxe.pie.cri.epita.fr";
        interval = "30s";
        conditions = [
          "[STATUS] == 200"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "K8s argocd";
        url = "https://argocd.k8s.cri.epita.fr";
        interval = "30s";
        conditions = [
          "[STATUS] == 200"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "K8s grafana";
        url = "https://grafana.k8s.cri.epita.fr";
        interval = "30s";
        conditions = [
          "[STATUS] == 200"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "Vault";
        url = "https://vault.cri.epita.fr";
        interval = "30s";
        conditions = [
          "[STATUS] == 200"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "Bookstack";
        url = "https://bookstack.cri.epita.fr";
        interval = "30s";
        conditions = [
          "[STATUS] == 200"
          "[RESPONSE_TIME] <= 1000"
        ];
      }
      {
        name = "OIDC redirection";
        url = "https://tickets.cri.epita.fr";
        interval = "30s";
        conditions = [
          "[STATUS] == 401"
          "[RESPONSE_TIME] <= 1000"
        ];
      }
      {
        name = "Blog";
        url = "https://blog.cri.epita.fr";
        interval = "30s";
        conditions = [
          "[STATUS] == 200"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "Nix Cache ❄️";
        url = "https://cache.nix.cri.epita.fr";
        interval = "30s";
        conditions = [
          "[STATUS] == 200"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "Documentation";
        url = "https://doc.cri.epita.fr";
        interval = "30s";
        conditions = [
          "[STATUS] == 200"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "Moodle (cours)";
        url = "https://moodle.cri.epita.fr";
        interval = "30s";
        conditions = [
          "[STATUS] == 200"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "Moodle (exams)";
        url = "https://moodle-exam.cri.epita.fr";
        interval = "30s";
        conditions = [
          "[STATUS] == 200"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "Rocket.Chat";
        url = "https://rocketchat.cri.epita.fr";
        interval = "30s";
        conditions = [
          "[STATUS] == 200"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "HTTPS redirection";
        url = "https://tickets.cri.epita.fr";
        interval = "30s";
        conditions = [
          "[STATUS] == 401"
          "[RESPONSE_TIME] <= 300"
        ];
      }
      {
        name = "Wiki prog";
        url = "https://wiki-prog.infoprepa.epita.fr";
        interval = "30s";
        conditions = [
          "[STATUS] == 200"
          "[RESPONSE_TIME] <= 1000"
        ];
      }
    ];
  };
  gatusConfigFile = toYAML "config.yaml" gatusConfig;

  prometheusConfig = {
    scrape_configs = [
      {
        job_name = "gatus";
        scrape_interval = "10s";
        scheme = "https";
        static_configs = [{
          targets = [ "devoups.online:443" ];
        }];
      }
    ];
  };
  prometheusConfigFile = toYAML "prometheus.yml" prometheusConfig;
in
{
  networking.firewall.allowedTCPPorts = [ 8080 9090 3000 ];

  docker-containers = {
    gatus = {
      image = "twinproduction/gatus";
      ports = [ "8080:8080" ];
      volumes = [ "${gatusConfigFile}:/config/config.yaml" ];
    };

    prometheus = {
      image = "prom/prometheus";
      cmd = [ "--config.file=/etc/prometheus/prometheus.yml" ];
      ports = [ "9090:9090" ];
      volumes = [
        "${prometheusConfigFile}:/etc/prometheus/prometheus.yml"
        "/persist/gratus/prometheus:/prometheus"
      ];
      extraDockerOptions = [
        "--user" "root"
      ];
    };

    grafana = {
      image = "grafana/grafana";
      ports = [ "3000:3000" ];
      volumes = [
        "${./grafana.ini}:/etc/grafana/grafana.ini:ro"
        "${./grafana-provisioning}:/etc/grafana/provisioning"
        "/persist/gratus/grafana:/var/lib/grafana"
      ];
      extraDockerOptions = [
        "--user" "root"
      ];
    };
  };
}
