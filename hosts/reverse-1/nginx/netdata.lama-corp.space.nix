{ pkgs, lib, ... }:

let
  awkFormatNginx = builtins.toFile "awkFormat-nginx.awk" ''
    awk -f
    {sub(/^[ \t]+/,"");idx=0}
    /\{/{ctx++;idx=1}
    /\}/{ctx--}
    {id="";for(i=idx;i<ctx;i++)id=sprintf("%s%s", id, "\t");printf "%s%s\n", id, $0}
   '';
in {
  nixpkgs.overlays = [
    (self: super: {
      writers = super.writers // {
        writeNginxConfig = name: text: pkgs.runCommandLocal name {
          inherit text;
          passAsFile = [ "text" ];
        } /* sh */ ''
          # nginx-config-formatter has an error - https://github.com/1connect/nginx-config-formatter/issues/16
          ${pkgs.gawk}/bin/awk -f ${awkFormatNginx} "$textPath" | ${pkgs.gnused}/bin/sed '/^\s*$/d' > $out
          ${pkgs.gixy}/bin/gixy --skips ssrf $out
        '';
      };
    })
  ];

  services.nginx.upstreams = {
    "netdata-kvm-1" = {
      servers."kvm-1.srv.fsn.lama-corp.space:19999" = {};
      extraConfig = "keepalive 64;";
    };
    "netdata-ldap-1" = {
      servers."ldap-1.vrt.fsn.lama-corp.space:19999" = {};
      extraConfig = "keepalive 64;";
    };
    "netdata-mail-1" = {
      servers."mail-1.vrt.fsn.lama-corp.space:19999" = {};
      extraConfig = "keepalive 64;";
    };
    "netdata-minio-1" = {
      servers."minio-1.vrt.fsn.lama-corp.space:19999" = {};
      extraConfig = "keepalive 64;";
    };
    "netdata-postgres-1" = {
      servers."postgres-1.vrt.fsn.lama-corp.space:19999" = {};
      extraConfig = "keepalive 64;";
    };
    "netdata-reverse-1" = {
      servers."reverse-1.vrt.fsn.lama-corp.space:19999" = {};
      extraConfig = "keepalive 64;";
    };
    "netdata-web-1" = {
      servers."web-1.vrt.fsn.lama-corp.space:19999" = {};
      extraConfig = "keepalive 64;";
    };
    "netdata-web-2" = {
      servers."web-2.vrt.fsn.lama-corp.space:19999" = {};
      extraConfig = "keepalive 64;";
    };
    "netdata-nas" = {
      servers."nas.srv.bar.lama-corp.space:19999" = {};
      extraConfig = "keepalive 64;";
    };
    "netdata-giraffe" = {
      servers."giraffe.srv.nbg.lama-corp.space:19999" = {};
      extraConfig = "keepalive 64;";
    };
  };

  services.nginx.virtualHosts."netdata.lama-corp.space" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-netdata.lama-corp.space.log netdata;
    '';
    locations = {
      "~ /(?<behost>.*)/(?<ndpath>.*)" = {
        proxyPass = "http://netdata-$behost/$ndpath$is_args$args";

        extraConfig = ''
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Server $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_http_version 1.1;
          proxy_pass_request_headers on;
          proxy_set_header Connection "keep-alive";
          proxy_store off;

          gzip on;
          gzip_proxied any;
          gzip_types *;
        '';
      };

      "~ /(?<behost>[^\\r\\n]*)".extraConfig = "return 301 /n/$behost/;";
    };
  };
}
