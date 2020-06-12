{ config, pkgs, lib, ... }:

let
  script = pkgs.writeTextFile {
    name = "lock.sh";
    executable = true;
    destination = "/bin/lock.sh";
    text = ''
      #! ${pkgs.runtimeShell}
      ${pkgs.i3lock-color}/bin/i3lock-color --clock --color=ffa500 --show-failed-attempts --bar-indicator --datestr='%A %Y-%m-%d' -i $(${pkgs.coreutils}/bin/shuf -n1 -e /home/risson/.lock-images/*.jpg)
    '';
  };
in {
    services.screen-locker.lockCmd = lib.mkForce "${script}/bin/lock.sh";
}
