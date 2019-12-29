{ pkgs, lib, ... }:

with lib;

let
  shabka = import <shabka> { };

  dotshabka = import ../.. { };

in {
  imports = [
    ./hardware-configuration.nix

    "${shabka.external.nixos-hardware.path}/common/cpu/intel"
    "${shabka.external.nixos-hardware.path}/common/pc/laptop"
    "${shabka.external.nixos-hardware.path}/common/pc/laptop/ssd"

    <shabka/modules/nixos>
    ../../modules/nixos

    ./home.nix
  ];

  services.dbus.packages = with pkgs; [ gnome3.dconf ];

  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0
  '';

  # set the default locale and the timeZone
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Paris";

  networking.hostName = "hedgehog";

  /*networking.localCommands = ''
    ip netns delete sw1 || true
    ip netns delete sw2 || true
    ip netns delete host1 || true
    ip netns delete host2 || true
    ip netns delete host3 || true
    ip netns delete host11 || true
    ip netns delete host12 || true
    ip netns delete host13 || true

    ip netns add sw1
    ip netns add sw2
    ip netns add host1
    ip netns add host2
    ip netns add host3
    ip netns add host11
    ip netns add host12
    ip netns add host13

    ip link add p1-sw1 type veth peer name p1-host1
    ip link set dev p1-sw1 netns sw1 up
    ip link set dev p1-host1 netns host1 up
    ip netns exec sw1 ${pkgs.ethtool}/bin/ethtool -K p1-sw1 tx off
    ip netns exec host1 ${pkgs.ethtool}/bin/ethtool -K p1-host1 tx off
    ip netns exec host1 ip address add 172.20.1.1/24 dev p1-host1

    ip link add p2-sw1 type veth peer name p2-host2
    ip link set dev p2-sw1 netns sw1 up
    ip link set dev p2-host2 netns host2 up
    ip netns exec sw1 ${pkgs.ethtool}/bin/ethtool -K p2-sw1 tx off
    ip netns exec host2 ${pkgs.ethtool}/bin/ethtool -K p2-host2 tx off
    ip netns exec host2 ip address add 172.20.1.2/24 dev p2-host2

    ip link add p3-sw1 type veth peer name p3-host3
    ip link set dev p3-sw1 netns sw1 up
    ip link set dev p3-host3 netns host3 up
    ip netns exec sw1 ${pkgs.ethtool}/bin/ethtool -K p3-sw1 tx off
    ip netns exec host3 ${pkgs.ethtool}/bin/ethtool -K p3-host3 tx off
    ip netns exec host3 ip address add 172.20.1.3/24 dev p3-host3

    ip link add p11-sw2 type veth peer name p11-host11
    ip link set dev p11-sw2 netns sw2 up
    ip link set dev p11-host11 netns host11 up
    ip netns exec sw2 ${pkgs.ethtool}/bin/ethtool -K p11-sw2 tx off
    ip netns exec host11 ${pkgs.ethtool}/bin/ethtool -K p11-host11 tx off
    ip netns exec host11 ip address add 172.20.1.11/24 dev p11-host11

    ip link add p12-sw2 type veth peer name p12-host12
    ip link set dev p12-sw2 netns sw2 up
    ip link set dev p12-host12 netns host12 up
    ip netns exec sw2 ${pkgs.ethtool}/bin/ethtool -K p12-sw2 tx off
    ip netns exec host12 ${pkgs.ethtool}/bin/ethtool -K p12-host12 tx off
    ip netns exec host12 ip address add 172.20.1.12/24 dev p12-host12

    ip link add p13-sw2 type veth peer name p13-host13
    ip link set dev p13-sw2 netns sw2 up
    ip link set dev p13-host13 netns host13 up
    ip netns exec sw2 ${pkgs.ethtool}/bin/ethtool -K p13-sw2 tx off
    ip netns exec host13 ${pkgs.ethtool}/bin/ethtool -K p13-host13 tx off
    ip netns exec host13 ip address add 172.20.1.13/24 dev p13-host13

    ip link add t-sw1 type veth peer name t-sw2
    ip link set dev t-sw1 netns sw1 up
    ip link set dev t-sw2 netns sw2 up
    ip netns exec sw1 ${pkgs.ethtool}/bin/ethtool -K t-sw1 tx off
    ip netns exec sw2 ${pkgs.ethtool}/bin/ethtool -K t-sw2 tx off
  '';*/

  shabka.hardware.intel_backlight.enable = true;
  shabka.printing.enable = true;
  shabka.users.enable = true;
  shabka.virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  shabka.keyboard.layouts = [ "bepo" "qwerty_intl" ];
  shabka.keyboard.enableAtBoot = false;

  shabka.workstation = {
    autorandr.enable = true;
    bluetooth.enable = true;
    fonts.enable = true;
    networking.enable = true;
    power.enable = true;
    sound.enable = true;
    teamviewer.enable = true;
    virtualbox.enable = true;
    xorg.enable = true;
  };

  shabka.hardware.machine = "thinkpad-e580";

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  users.users.root.openssh.authorizedKeys.keys = singleton dotshabka.external.risson.keys;
  shabka.users.users = {
    risson = {
      uid = 2000;
      isAdmin = true;
      home ="/home/risson";
      hashedPassword = "$6$2YnxY3Tl$kRj7YZypnB2Od41GgpwYRcn4kCcCE6OksZlKLws0rEi//T/emKWEsUZZ2ZG40eph1bpmjznztav4iKc8scmqc1";
      sshKeys = singleton dotshabka.external.risson.keys;
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
