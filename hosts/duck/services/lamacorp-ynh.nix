{ config, lib, pkgs, ... }:
{
  services.nginx.upstreams."lamacorp-ynh" = {
    servers = { "172.20.20.2".backup = false; };
  };
  services.nginx.virtualHosts."hub.lama-corp.space" = {
    serverAliases = [
      "cloud.lama-corp.space"
      "chat.lama-corp.space"
      "apps.lama-corp.space"
      "git.lama-corp.space"
    ];
    listen = [ { addr = "0.0.0.0"; port = 80; } { addr = "0.0.0.0"; port = 443; } ];
    locations."/" = {
      proxyPass = "lamacorp-ynh";
    };
  };
}
