{ soxincfg, config, pkgs, lib, ... }:

let
  smartHosts = pkgs.stdenv.mkDerivation {
    name = "smart-hosts";

    src = pkgs.fetchurl {
      url = "http://infra.smartadserver.com/get-hosts.asp";
      sha256 = "sha256-qnyCsVQJKEzI317imiwl5Sgh/tGVZhhnAYfLwBOlcxc=";
    };

    phases = [ "buildPhase" ];

    buildInputs = [ pkgs.dos2unix ];

    buildPhase = ''
      dos2unix --newfile $src tmp

      # Remove n-1 lines from the beginning of the file
      tail -n +4 tmp > tmp2


      # Remove n-1 lines from the end of the file
      head -n -3 tmp2 > $out
    '';
  };
in
{
  networking = {
    hostName = "sas";
    domain = "rsn.lama.tel";
    hostId = "8425e349";

    extraHosts = ''
      10.3.10.18 infra.smartadserver.com
    '';

    hostFiles = [ smartHosts ];

    nameservers = [ "1.1.1.1" ];

    useDHCP = true;

    /*dhcpcd.extraConfig = ''
      nohook resolv.conf
    '';*/

    wireless = {
      enable = true;
      interfaces = [ "wlp0s20f3" ];
    };

    firewall = {
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  sops.secrets.wpa_supplicant = {
    sopsFile = ./wpa_supplicant.yml;
    path = "/etc/wpa_supplicant.conf";
  };
}
