{ ... }:

{
  shabka.virtualisation = { docker.enable = true; };

  # TODO: package this and run it as a service
  docker-containers."cloudflare-ddns-ipv4" = {
    image = "oznu/cloudflare-ddns";
    environment = {
      ZONE = "lama-corp.space";
      SUBDOMAIN = "bar";
      PROXIED = "false";
      RRTYPE = "A";
    };
    extraDockerOptions = [ "--network=host" ];
  };

  docker-containers."cloudflare-ddns-ipv6" = {
    image = "oznu/cloudflare-ddns";
    environment = {
      ZONE = "lama-corp.space";
      SUBDOMAIN = "bar";
      PROXIED = "false";
      RRTYPE = "AAAA";
    };
    extraDockerOptions = [ "--network=host" ];
  };
}
