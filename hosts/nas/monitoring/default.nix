{ ... }:

{
  services.smartd = {
    enable = true;
    extraOptions = [
      "-A /var/log/smartd/"
      "--interval=600"
    ];
    devices = [
      { device = "/dev/sda"; }
      { device = "/dev/sdb"; }
      { device = "/dev/sdc"; }
    ];
  };

  services.logrotate = {
    enable = true;
    config = ''
      compress
      /var/log/smartd/* {
        rotate 5
        weekly
        olddir /var/log/smartd/old
      }
    '';
  };
}
