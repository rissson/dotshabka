{ config, pkgs, lib, ... }:

with lib;

{
  services.codimd = {
    enable = false; # enabled by secrets
    workDir = "/srv/codimd";
    configuration = {
      allowAnonymous = true;
      allowAnonymousEdits = true;
      allowEmailRegister = true;
      allowOrigin = [
        "md.lama-corp.space"
        "md.risson.space"
        "md.marcerisson.space"
        "md.risson.me"
        "md.risson.tech"
      ];
      defaultPermission = "freely";
      domain = "md.lama-corp.space";
      email = true;
      hsts.enable = false;
      imageUploadType = "filesystem";
      useCDN = false;
      host = "localhost";
      port = 19100;
      protocolUseSSL = true;
    };
  };

  services.nginx.virtualHosts."md.lama-corp.space" = {
    serverAliases = [
      "md.risson.space"
      "md.marcerisson.space"
      "md.risson.me"
      "md.risson.tech"
    ];
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-md.lama-corp.space.log netdata;
    '';
    locations = {
      "/" = {
        proxyPass = "http://localhost:19100";
        extraConfig = ''
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };
}
