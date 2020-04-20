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
}
