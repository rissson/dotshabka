{ config, lib, pkgs, ... }:
{
  services.nginx.virtualHosts."beauflard.risson.space" = {
    serverAliases = [
      "beauflard.risson.me"
      "beauflard.marcerisson.space"
      "beauflard.risson.rocks"
      "beauflard.risson.tech"
    ];
    forceSSL = true;
    enableACME = true;
    root = "/srv/http/beauflard";
    locations = {
      "/" = {
        index = "index.php index.html index.htm";
      };
      "~ [^/]\.php(/|$)" = {
        tryFiles = "$uri $document_root$fastcgi_script_name =404";
        extraConfig = ''
          fastcgi_split_path_info ^(.+\.php)(/.+)$;
          fastcgi_pass unix:${config.services.phpfpm.pools."beauflard".socket};
          fastcgi_param HTTP_PROXY "";
          fastcgi_index index.php;
          include ${pkgs.nginx}/conf/fastcgi_params;
          include ${pkgs.nginx}/conf/fastcgi.conf;
        '';
      };
    };
  };

  services.phpfpm.pools."beauflard" = {
    user = "nginx";
    group = "deploy";
    #if needed phpOptions = "";
    settings = {
      "pm" = "dynamic";
      "pm.max_children" = "8";
      "pm.max_requests" = "500";
      "pm.start_servers" = "1";
      "pm.min_spare_servers" = "1";
      "pm.max_spare_servers" = "5";
      "listen.owner" = "nginx";
      "listen.group" = "deploy";
      "php_admin_value[error_log]" = "'stderr'";
      "php_admin_flag[log_errors]" = "on";
      "env[PATH]" = "${lib.makeBinPath [ pkgs.php ]}";
      "catch_workers_output" = "yes";
    };
  };
}
