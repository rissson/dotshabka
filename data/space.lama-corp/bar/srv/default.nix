{ ... }:

{
  start = "192.168.44.240";
  end = "192.168.44.255";

  cuckoo = import ./cuckoo { };

  nas = import ./nas { };

  livebox = import ./livebox { };
}
