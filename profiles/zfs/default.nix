{ pkgs, ... }:

{
  imports = [ ../sendmail ];

  boot.loader.grub.zfsSupport = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelParams = [ "elevator=none" ];

  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
    };

    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc -v";
      frequent = 4;
      hourly = 24;
      daily = 7;
      weekly = 4;
      monthly = 12;
    };

    trim = {
      enable = true;
      interval = "weekly";
    };

    zed.settings = {
      ZED_EMAIL_ADDR = "root@lama-corp.ovh";
      ZED_EMAIL_PROG = "${pkgs.system-sendmail}/bin/sendmail";
      ZED_EMAIL_OPTS = "@ADDRESS@";
    };
  };
}
