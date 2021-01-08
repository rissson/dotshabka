{ ... }:

{
  services.haproxy = {
    enable = true;
    config = ''
        # global configuration is above
        log /dev/log local0
        log /dev/log local1 notice

      defaults
        mode tcp
        log global
        option tcplog
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

      backend k8s-fsn-ingress
        server k8s-fsn-ingress ingress.k8s.lama-corp.space:80
      backend k8s-fsn-ingress-tls
        server k8s-fsn-ingress ingress.k8s.lama-corp.space:443

      frontend k8s-fsn-ingress
        bind [2a01:4f8:242:1910::1]:80
        use_backend k8s-fsn-ingress
      frontend k8s-fsn-ingress-tls
        bind [2a01:4f8:242:1910::1]:443
        use_backend k8s-fsn-ingress-tls
    '';
  };
}
