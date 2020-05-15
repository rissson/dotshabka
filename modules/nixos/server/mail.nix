{ config, ... }:

let
  hostname = with config.networking; "${hostName}.${domain}";
in {
  services.postfix = {
    enable = true;
    inherit hostname;
    domain = config.networking.domain;
  };
}
