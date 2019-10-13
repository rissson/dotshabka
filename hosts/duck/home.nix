{
  shabka.home-manager.config = { userName, uid, isAdmin, home, nixosConfig }:
  { lib, ... }:

  with lib;

  {
    imports = [
      <shabka/modules/home>
      ../../modules/home
    ];

    shabka.nixosConfig = nixosConfig;

    shabka.keyboard.layouts = [ "qwerty_intl" ];

    shabka.git.enable = true;
    shabka.gnupg.enable = true;
    shabka.htop.enable = true;
    shabka.ssh.enable = true;
    shabka.tmux.enable = true;
    shabka.weechat.enable = true;
    shabka.neovim.enable = true;
    shabka.neovim.keyboardLayout = "qwerty";
  };
}
