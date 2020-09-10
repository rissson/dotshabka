{ config, lib, inputs, ... }:

with lib;

let
  cfg = config.lama-corp.common.users;
in {
  options = {
    lama-corp.common.users.enable = mkEnableOption "Enable common users";
  };

  config = mkIf cfg.enable {
    users.users.root = with inputs.self.vars.users; {
      hashedPassword =
        "$6$6gHewlCr$qLfWzM/s0Olmaps2wyVfV83xVDXenGlJA.Sza.hoNFOvtue81L9I.wXVylZQ0eu68fl1NEsjjGIqnBTuoJDT..";
      openssh.authorizedKeys.keys = risson.sshKeys ++ diego.sshKeys;
    };
  };
}
