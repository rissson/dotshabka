{ soxincfg, config, pkgs, lib, ... }:

let
  smartHosts = pkgs.stdenv.mkDerivation {
    name = "smart-hosts";

    src = pkgs.fetchurl {
      url = "http://infra.smartadserver.com/get-hosts.asp";
      sha256 = "sha256-65Rlw7DHh1AkMz+JxCOqj2AIqupHPAbVLhEMoUoA+vA=";
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
      allowedTCPPorts = [ 6567 ];
      allowedUDPPorts = [ 6567 ];
    };
  };

  services.openvpn.servers = {
    smart-eqx = { config = ''config /persist/secrets/smart-openvpn/eqx.ovpn''; autoStart = false; };
    smart-itx4 = { config = ''config /persist/secrets/smart-openvpn/itx4.ovpn''; autoStart = false; };
    smart-itx5 = { config = ''config /persist/secrets/smart-openvpn/itx5.ovpn''; autoStart = false; };
    smart-tmk = { config = ''config /persist/secrets/smart-openvpn/tmk.ovpn''; autoStart = false; };

    smart-smart = { config = ''config /persist/secrets/smart-openvpn/mschmitt.ovpn''; autoStart = true; };
  };

  systemd.services.openvpn-smart-smart = {
    path = [ (pkgs.python3.withPackages (ps: with ps; [ pyotp ])) ];
    preStart = ''
      echo mschmitt > /persist/secrets/smart-openvpn/credentials
      python3 -c "import pyotp; print(pyotp.TOTP('$(cat /persist/secrets/smart-openvpn/mschmitt.google_authenticator.txt | head -n1 )').now())" >> /persist/secrets/smart-openvpn/credentials
    '';
  };

  sops.secrets.wpa_supplicant = {
    sopsFile = ./wpa_supplicant.yml;
    path = "/etc/wpa_supplicant.conf";
  };
}
