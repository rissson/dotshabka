{ ... }:

with import <dotshabka/data/space.lama-corp/bar/srv/cuckoo> { };

{
  networking = {
    hostName = "cuckoo"; # Define your hostname.
    domain = "srv.bar.lama-corp.space";

    bridges = {
      "${internal.interface}" = {
        interfaces = internal.bridgeInterfaces;
      };
    };

    useDHCP = false;
    interfaces = {
      "${internal.interface}" = {
        useDHCP = true;
        macAddress = internal.mac;
      };
    };
  };

  services.hostapd = {
    enable = true;
    interface = internal.wifiInterface;
    channel = 0;
    ssid = "hello_world";
    wpa = true;
    extraConfig = ''
      bridge=${internal.interface}
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
