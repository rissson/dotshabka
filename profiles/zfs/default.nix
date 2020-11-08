{ pkgs, ... }:

{
  boot = {
    kernelParams = [ "elevator=none" ];
    supportedFilesystems = [ "zfs" ];
    loader.grub.zfsSupport = true;
  };

  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
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

    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc -v";
      frequent = 8;
      hourly = 48;
      daily = 14;
      weekly = 8;
      monthly = 13;
    };
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOq4oAEpzV8mfFa2ub2WBJXZ2aqZaeDYhtuyzPZIiq5W syncoid@nas-1.srv.bar.lama-corp.space"
    ];
  };

  environment.systemPackages = with pkgs; [
    lzop
    mbuffer
  ];
}
