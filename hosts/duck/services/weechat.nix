{ config, pkgs, lib, ... }:
{
  #TODO(medium): screen -> tmux
  #TODO(high): move this to shabka and let every user enable it if he wants.
  #            Also, wait before shabka is suited for multi-user
  systemd.services.weechat-risson = {
    environment.WEECHAT_HOME = "${config.users.users.risson.home}/.weechat";
    serviceConfig = {
      User = "risson";
      RemainAfterExit = "yes";
    };
    script = "exec ${config.security.wrapperDir}/screen -Dm -S weechat-risson ${config.services.weechat.binary}";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network.target" ];
  };

  security.wrappers.screen.source = "${pkgs.screen}/bin/screen";
}
