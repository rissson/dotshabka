{ ... }:

{
  start = "192.168.44.240";
  end = "192.168.44.249";

  floor0 = import ./floor0 { };

  floor-1 = import ./floor-1 { };
}
