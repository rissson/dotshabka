{ ... }:

{
  start = "192.168.44.220";
  end = "192.168.44.229";

  loewe = import ./loewe { };

  bose = import ./bose { };

  chromecast = import ./chromecast { };
}
