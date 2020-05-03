{ config, pkgs, lib, ... }:

let port = 8001;
in {
  networking.firewall.allowedTCPPorts = [ port ];
  services.nginx.virtualHosts."beauflard.risson.space" = {
    serverName = "_";
    default = true;
    listen = [
      { addr = "0.0.0.0"; inherit port; }
      { addr = "[::]"; inherit port; }
    ];
    root = "/srv/beauflard.risson.space";
    locations = {
      "/" = { index = "index.php index.html index.htm"; };
      "~ [^/]\\.php(/|$)" = {
        tryFiles = "$uri $document_root$fastcgi_script_name =404";
        extraConfig = ''
          fastcgi_split_path_info ^(.+\.php)(/.+)$;
          fastcgi_pass unix:${config.services.phpfpm.pools."beauflard.risson.space".socket};
          fastcgi_param HTTP_PROXY "";
          fastcgi_index index.php;
          include ${pkgs.nginx}/conf/fastcgi_params;
          include ${pkgs.nginx}/conf/fastcgi.conf;
        '';
      };
      "/status" = {
        extraConfig = ''
          access_log off;
          allow 127.0.0.1;
          allow 172.28.0.0/16;
          allow fd00:7df7:e9a5::/48;
          deny all;
          fastcgi_pass unix:${config.services.phpfpm.pools."beauflard.risson.space".socket};
          include ${pkgs.nginx}/conf/fastcgi_params;
          include ${pkgs.nginx}/conf/fastcgi.conf;
        '';
      };
    };
  };

  services.phpfpm.pools."beauflard.risson.space" = {
    inherit (config.services.nginx) user group;
    settings = {
      "pm" = "dynamic";
      "pm.max_children" = "8";
      "pm.max_requests" = "500";
      "pm.start_servers" = "1";
      "pm.min_spare_servers" = "1";
      "pm.max_spare_servers" = "5";
      "pm.status_path" = "/status";
      "listen.owner" = config.services.nginx.user;
      "listen.group" = config.services.nginx.group;
      "php_admin_value[error_log]" = "'stderr'";
      "php_admin_flag[log_errors]" = "on";
      "env[PATH]" = "${lib.makeBinPath [ pkgs.php ]}";
      "catch_workers_output" = "yes";
    };
  };
}
