{ ... }:

{
  networking.firewall.allowedTCPPorts = [ 6443 6444 ];

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

      backend k8s-fsn-apiserver
        mode tcp
        server k8s-fsn-apiserver 172.28.7.10:6443
      frontend k8s-fsn-apiserver
        bind 168.119.71.47:6443
        mode tcp
        use_backend k8s-fsn-apiserver

      backend k3s-fsn-apiserver
        mode tcp
        server k3s-fsn-apiserver 172.28.7.1:6443
      frontend k3s-fsn-apiserver
        bind 168.119.71.47:6444
        mode tcp
        use_backend k3s-fsn-apiserver
    '';
  };
}
