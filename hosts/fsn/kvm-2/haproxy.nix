{ ... }:

{
  networking.firewall.allowedTCPPorts = [ 6443 ];

  services.haproxy = {
    enable = true;
    config = ''
        # global configuration is above
        log /dev/log local0
        log /dev/log local1 notice

      defaults
        mode tcp
        log global
        option dontlognull
        option forwardfor except 127.0.0.0/8
        option redispatch
        retries 1
        timeout http-request 10s
        timeout queue 20s
        timeout connect 5s
        timeout client 20s
        timeout server 20s
        timeout http-keep-alive 10s
        timeout check 10s

      backend k8s-fsn-apiserver
        mode tcp
        server k8s-fsn-apiserver 172.28.7.1:6443
      frontend k8s-fsn-apiserver
        bind 168.119.71.47:6443
        mode tcp
        use_backend k8s-fsn-apiserver
    '';
  };
}
