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

    home.file.".gnupg/scdaemon.conf".text = ''
      reader-port Yubico YubiKey
      disable-ccid
      card-timeout 5
    '';

    shabka.keyboard.layouts = [ "bepo" "qwerty_intl" ];
    home.keyboard.options = [ "grp:alt_caps_toggle" "caps:swapescape" ];

    shabka.batteryNotifier.enable = true;
    shabka.git.enable = true;
    shabka.gnupg.enable = true;
    shabka.htop.enable = true;
    shabka.keybase.enable = true;
    shabka.syncthing.enable = true;
    shabka.ssh.enable = true;
    shabka.tmux.enable = true;
    shabka.neovim.enable = true;
    shabka.neovim.keyboardLayout = "qwerty";
    shabka.workstation = {
      enable = true;
      alacritty.enable = mkForce false;
      dunst.enable = mkForce false;
      greenclip.enable = mkForce false;
      termite.enable = mkForce false;
      chromium.enable = mkForce false; # until it's more generic in shabka
      firefox.enable = mkForce false;
      i3 = {
        enable = true;
        bar = {
          polybar.enable = true;
          location = "top";
          modules = {
            backlight.enable = true;
            battery = {
              enable = true;
              devices = [ { device = "BAT0"; fullAt = 100; } ];
            };
            cpu.enable = true;
            time = {
              enable = true;
              timezones = [
                { timezone = "Europe/Paris"; prefix = "FR"; format = "%a %Y-%m-%d %H:%M:%S"; }
                { timezone = "UTC"; prefix = "UTC"; format = "%H:%M:%S"; }
              ];
            };
            ram.enable = true;
            network = {
              enable = true;
              eth = [ "enp3s0" ];
              wlan = [ "wlp5s0" ];
            };
            volume.enable = true;
            spotify.enable = false;
            keyboardLayout.enable = true;
          };
        };
      };
      rofi.enable = true;
      urxvt.enable = true;
      bluetooth.enable = true;
      gtk.enable = true;
      locker.enable = true;
    };

    ## TBD once fixed in shabka
    home.file.".config/chromium/profiles/epita/.keep".text = "";
    home.file.".config/chromium/profiles/lamacorp/.keep".text = "";
    home.file.".mozilla/firefox/profiles/epita/.keep".text = "";
    home.file.".mozilla/firefox/profiles/lamacorp/.keep".text = "";
    home.file.".mozilla/firefox/profiles/personal/.keep".text = "";
    home.file.".mozilla/firefox/profiles.ini".text = ''
      [General]
      StartWithLastProfile=1

      [Profile0]
      Name=personal
      IsRelative=1
      Path=profiles/personal
      Default=1

      [Profile1]
      Name=profiles/epita
      IsRelative=1
      Path=epita

      [Profile2]
      Name=lamacorp
      IsRelative=1
      Path=profiles/lamacorp
    '';
    ## END TBD


    xresources = {
      properties = {
        "*foreground" = "#b2b2b2";
        "*background" = "#020202";
      };
    };
  };
}
