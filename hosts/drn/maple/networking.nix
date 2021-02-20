{ ... }:

{
  networking = {
    hostName = "maple"; # Define your hostname.
    domain = "lap.drn.lama-corp.space";
    hostId = "8425e349";

    useDHCP = false;

    wireless = {
      enable = true;
      interfaces = [ "wlp5s0" ];
    };
    interfaces.enp3s0.useDHCP = true;
    interfaces.wlp5s0.useDHCP = true;
  };

  networking.wireless.extraConfig = ''
    ctrl_interface=/run/wpa_supplicant
    ctrl_interface_group=wheel
  '';

}
