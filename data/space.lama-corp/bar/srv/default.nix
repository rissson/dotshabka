{ ... }:

{
  start = "192.168.44.200";
  end = "192.168.44.209";

  cuckoo = import ./cuckoo { };

  nas = import ./nas { };

  livebox = import ./livebox { };
}
