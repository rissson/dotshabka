{ ... }:

{
  services.nginx = {
    upstreams."chat-lama-corp-space" = {
      servers = {
        "web-2.vrt.fsn.lama-corp.space:19065" = {};
      };
    };

    virtualHosts."chat.lama-corp.space" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        access_log /var/log/nginx/access-chat.lama-corp.space.log netdata;
      '';
      locations = {
        "~ /api/v[0-9]+/(users/)?websocket$" = {
          proxyPass = "http://chat-lama-corp-space";
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            client_max_body_size 50M;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Frame-Options SAMEORIGIN;
            proxy_buffers 256 16k;
            proxy_buffer_size 16k;
            client_body_timeout 60;
            send_timeout 300;
            lingering_timeout 5;
            proxy_connect_timeout 90;
            proxy_send_timeout 300;
            proxy_read_timeout 90s;
          '';
        };
        "/" = {
          proxyPass = "http://chat-lama-corp-space";
          # TODO: enable cache?
          extraConfig = ''
            client_max_body_size 50M;
            proxy_set_header Connection "";
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Frame-Options SAMEORIGIN;
            proxy_buffers 256 16k;
            proxy_buffer_size 16k;
            proxy_read_timeout 600s;
            #proxy_cache mattermost_cache;
            #proxy_cache_revalidate on;
            #proxy_cache_min_uses 2;
            #proxy_cache_use_stale timeout;
            #proxy_cache_lock on;
            #proxy_http_version 1.1;
          '';
        };
      };
    };
  };
}
