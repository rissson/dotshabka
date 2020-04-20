{ config, lib, pkgs, ... }:

with lib;

let
  nixpkgs = import (import <shabka> {}).external.nixpkgs.release-unstable.path {};
in {
  nixpkgs.overlays = [
    (self: super: {
      netdata = nixpkgs.netdata;
    })
  ];

  services.netdata.enable = true;

  environment.etc = mkIf config.services.netdata.enable {
    "netdata/fping.conf".text = ''
      fping="${pkgs.fping}/bin/fping"
      hosts="duck.srv.fsn.lama-corp.space hub.virt.duck.srv.fsn.lama-corp.space nas.srv.bar.lama-corp.space"
    '';
  };

  security.wrappers."fping.plugin" = mkIf config.services.netdata.enable {
    source = "${pkgs.netdata}/libexec/netdata/plugins.d/fping.plugin";
    capabilities = "cap_net_raw+ep";
    owner = config.services.netdata.user;
    group = config.services.netdata.group;
    permissions = "u+rx,g+rx,o-rwx";
  };
}
