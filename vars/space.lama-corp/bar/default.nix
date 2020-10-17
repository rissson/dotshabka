{ ... }:

{
  subnet = "192.168.44.0/24";

  dhcp = {
    start = "192.168.44.100";
    end = "192.168.44.199";
  };

  srv = import ./srv { };

  mmd = import ./mmd { };

  prt = import ./prt { };

  wfi = import ./wfi { };
}
