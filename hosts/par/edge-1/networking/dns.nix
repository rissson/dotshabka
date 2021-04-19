{ dns, pkgs, ... }:

let
  lamaTelZoneFile = pkgs.writeText "lama.tel.zone" (dns.lib.toString "lama.tel" lamaTelZone);
  lamaTelZone = with dns.lib.combinators; {
    SOA = {
      nameServer = "ns1.lama.tel.";
      adminEmail = "hostmaster@lama-corp.space";
      serial = 2021041902;
      retry = 3600;
      minimum = 300;
    };

    NS = [ "ns1" "ns2" ];

    subdomains = {
      ns1 = host "108.61.208.236" null;
      ns2 = host "185.101.96.121" null;
    };
  };
in
{
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.bind = {
    enable = true;
    cacheNetworks = [ "127.0.0.0/8" "172.28.0.0/16" "::1/128" ];
    forwarders = [ "1.1.1.1" "1.0.0.1" ];

    zones = [
      {
        name = "lama.tel";
        file = lamaTelZoneFile;
        master = true;
        slaves = [
          "172.28.254.5"
        ];
      }
    ];
  };
}
