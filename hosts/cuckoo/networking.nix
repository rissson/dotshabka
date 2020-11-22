{ ... }:

{
  networking = {
    hostName = "cuckoo"; # Define your hostname.
    domain = "srv.bar.lama-corp.space";
    hostId = "448ab20b";

    bridges = {
      br0 = {
        interfaces = [ "enp4s11" "wls33" ];
      };
    };

    useDHCP = false;
    interfaces = {
      br0 = {
        useDHCP = true;
        macAddress = "12:e0:00:d1:5d:c7";
      };
    };
  };

  services.hostapd = {
    enable = true;
    interface = "wls33";
    channel = 0;
    ssid = "hello_world";
    wpa = true;
    extraConfig = ''
      bridge=br0
      ieee80211d=1
      country_code=FR
      ieee80211n=1
      wmm_enabled=1
      auth_algs=1
      wpa_key_mgmt=WPA-PSK
      wpa_pairwise=TKIP
      rsn_pairwise=CCMP
      macaddr_acl=0
    '';
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };
}
