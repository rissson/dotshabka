{ ... }:

{
  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-k -p --utc -v";
    frequent = 4;
    hourly = 24;
    daily = 7;
    weekly = 4;
    monthly = 12;
  };
}
