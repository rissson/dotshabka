{ lib, ... }:

with lib;

let

  dotshabka = import ../.. {};

  hostsFile = pkgs.writeTextFile {
    name = "hosts";
    executable = false;
    destination = "/share/hosts";
    text = with dotshabka.data.iPs.space.lama-corp; ''
      ${fsn.srv.duck.wg.v4.ip}          duck      duck.srv.fsn.lama-corp.space
      ${fsn.srv.duck.virt.hub.wg.v4.ip} hub       hub.virt.duck.srv.fsn.lama-corp.space

      ${bar.srv.nas.wg.v4.ip}           nas       nas.srv.bar.lama-corp.space

      ${fly.lap.hedgehog.wg.v4.ip}      hedgehog  hedgehog.lap.fly.lama-corp.space
    '';
  };
in {
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;

    servers = dotshabka.data.iPs.externalNameservers;
    extraConfig = ''
      ### Global settings

      # Interface not to listen on
      interface=${srv.nas.wg.interface}
      # Bind only to the others
      bind-interfaces

      ### DNS settings

      # Number of DNS queries cached
      cache-size=1000
      no-negcache
      domain-needed
      bogus-priv
      no-poll
      no-hosts
      no-resolv
      expand-hosts
      addn-hosts=${hostsFile}/share/hosts

      ### DNS hosts and domains

      local=/bar.lama-corp.space/
      domain=bar.lama-corp.space
    '';
  };
}
