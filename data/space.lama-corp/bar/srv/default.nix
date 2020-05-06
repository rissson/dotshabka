{ ... }:

{
  start = "192.168.44.240";
  end = "192.168.44.255";

  nas = import ./nas { };

  livebox = import ./livebox { };
}
