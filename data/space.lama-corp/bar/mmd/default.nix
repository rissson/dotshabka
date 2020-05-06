{ ... }:

{
  start = "192.168.44.220";
  end = "192.168.44.229";

  bose = import ./bose { };

  chromecast = import ./chromecast { };

  cuckoo = import ./cuckoo { };

  loewe = import ./loewe { };
}
