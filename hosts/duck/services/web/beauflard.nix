{ config, lib, pkgs, ... }:
{
  services.nginx.virtualHosts."beauflard.risson.space" = {
    serverAliases = [
      "beauflard.risson.me"
      "beauflard.marcerisson.space"
      "beauflard.risson.tech"
    ];
    forceSSL = true;
    enableACME = true;
    root = "/srv/http/beauflard";
    extraConfig = ''
      access_log /var/log/nginx/access-beauflard.risson.space.log netdata;
    '';
    locations = {
      "/" = {
        index = "index.php index.html index.htm";
      };
      "~ [^/]\\.php(/|$)" = {
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
      "/status" = {
        extraConfig = ''
          access_log off;
          allow 127.0.0.1;
          allow 172.28.0.0/16;
          allow 148.251.50.190;
          allow 148.251.148.232/29;
          allow 2a01:4f8:202:1097::/64;
          deny all;
          fastcgi_pass unix:${config.services.phpfpm.pools."beauflard".socket};
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
      "pm.status_path" = "/status";
      "listen.owner" = "nginx";
      "listen.group" = "deploy";
      "php_admin_value[error_log]" = "'stderr'";
      "php_admin_flag[log_errors]" = "on";
      "env[PATH]" = "${lib.makeBinPath [ pkgs.php ]}";
      "catch_workers_output" = "yes";
    };
  };
}
