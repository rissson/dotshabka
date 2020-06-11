{ config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.profiles.server;
in {
  options = {
    lama-corp.profiles.server = {
      enable = mkEnableOption "Enable profile for server hosts";
      enableRootUser = mkOption {
        type = types.bool;
        default = cfg.enable;
      };
    };
  };

  config = mkMerge [
    (optionalAttrs cfg.enable {
      lama-corp.common.enable = true;
      lama-corp.netdata.enable = true;
      lama-corp.ssh.enable = true;
      lama-corp.zfs.enable = true;

      powerManagement.cpuFreqGovernor = "performance";
    })

    (optionalAttrs cfg.enableRootUser {
      users.users.root = with import <dotshabka/data/users> { }; {
        hashedPassword =
          "$6$6gHewlCr$qLfWzM/s0Olmaps2wyVfV83xVDXenGlJA.Sza.hoNFOvtue81L9I.wXVylZQ0eu68fl1NEsjjGIqnBTuoJDT..";
        openssh.authorizedKeys.keys = risson.sshKeys ++ diego.sshKeys;
      };
    })
  ];
}
