{ soxincfg, config, pkgs, lib, ... }:

{
  imports = [
    ./wireguard.nix
  ];

  networking = {
    hostName = "hedgehog";
    domain = "lap.rsn.lama-corp.space";
    hostId = "daec192f";

    nameservers = [ "172.28.254.6" "1.1.1.1" ];

    useDHCP = true;

    /*dhcpcd.extraConfig = ''
      nohook resolv.conf
    '';*/

    wireless = {
      enable = true;
      interfaces = [ "wlp1s0" ];
    };

    localCommands = let ethtool = "${pkgs.ethtool}/bin/ethtool"; in ''
      ip link del myfw-in-nsin
      ip link del myfw-in-nsfw
      ip link del myfw-out-nsout
      ip link del myfw-out-nsfw

      ip netns delete nsin
      ip netns delete nsfw
      ip netns delete nsout

      ip netns add nsin
      ip netns add nsfw
      ip netns add nsout

      ip link add myfw-in-nsin type veth peer name myfw-in-nsfw
      ip link set dev myfw-in-nsin netns nsin up
      ip link set dev myfw-in-nsfw netns nsfw up

      ip netns exec nsin ${ethtool} -K myfw-in-nsin tx off
      ip netns exec nsfw ${ethtool} -K myfw-in-nsfw tx off

      ip netns exec nsin ip addr add fd00::0/127 dev myfw-in-nsin

      ip link add myfw-out-nsout type veth peer name myfw-out-nsfw
      ip link set dev myfw-out-nsout netns nsout up
      ip link set dev myfw-out-nsfw netns nsfw up

      ip netns exec nsout ${ethtool} -K myfw-out-nsout tx off
      ip netns exec nsfw ${ethtool} -K myfw-out-nsfw tx off

      ip netns exec nsout ip addr add fd00::1/127 dev myfw-out-nsout
    '';
  };

  sops.secrets.wpa_supplicant = {
    sopsFile = ./wpa_supplicant.yml;
    path = "/etc/wpa_supplicant.conf";
  };
}
