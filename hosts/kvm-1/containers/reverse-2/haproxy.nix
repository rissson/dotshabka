{ ... }:

{
  services.haproxy = {
    enable = true;
    config = ''
      backend minecraft-1
        balance roundrobin
        server minecraft-1 minecraft-1.containers:25505

      frontend minecraft-1
        bind *:25505
        use_backend minecraft-1
    '';
  };
}
