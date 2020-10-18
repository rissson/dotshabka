# TODO(high): This module must be gated by options, specially the mosh firewall one.

{ config, lib, ... }:

with lib;

let
  extraSocketSupport = ''
    StreamLocalBindUnlink yes
  '';

in {
  services.openssh.enable = true;

  # Support for my workflow. This can be removed once SWM v2 lands.
  services.openssh.extraConfig = extraSocketSupport;

  # allow Mosh server in
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
}
