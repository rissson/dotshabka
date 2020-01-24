{ lib, ... }:

with lib;

{
  imports = [
    <shabka/modules/home>
    ../../modules/home
  ];

  shabka.nixosConfig = {};

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
    autorandr.enable = true;
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
            devices = [ { device = "BAT0"; fullAt = 97; } ];
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
            eth = [ "eno1" ];
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
  home.file.".config/chromium/profiles/default/.keep".text = "";
  home.file.".mozilla/firefox/profiles/epita/.keep".text = "";
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
  '';
  ## END TBD


  xresources = {
    properties = {
      "*foreground" = "#b2b2b2";
      "*background" = "#020202";
    };
  };

  programs.autorandr.profiles = {
    "default" = {
      fingerprint = {
        VGA1 = "00ffffffffffff0026cd4161120500001d1c010368351e782aee35a656529d280b5054b30c00714f818081c081009500b300d1c00101023a801871382d40582c45000f282100001e000000fd00374c1e5311000a202020202020000000ff0031313634384d38373031323938000000fc00504c32343933480a202020202000aa";
        DP1 = "00ffffffffffff004c2dcc0b59324c3023190104b54728783ae691a7554ea0250c5054bfef80714f810081c08180a9c0b30095000101565e00a0a0a0295030203500c48e2100001a000000fd00384b1e5a19000a202020202020000000fc00533332443835300a2020202020000000ff00485448473830303431330a2020012002030ef041102309070783010000023a801871382d40582c4500c48e2100001e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa";
        DP2 = "00ffffffffffff0026cd4161a6040000181c0104a5351e783aee35a656529d280b5054b30c00714f818081c081009500b300d1c00101023a801871382d40582c45000f282100001e000000fd00374c1e5311000a202020202020000000ff0031313634384d38363031313930000000fc00504c32343933480a202020202001d7020318f14b9002030411121305141f012309070183010000023a801871382d40582c45000f282100001e8c0ad08a20e02d10103e96000f2821000018011d007251d01e206e2855000f282100001e8c0ad090204031200c4055000f28210000180000000000000000000000000000000000000000000000000000000000000035";
      };

      config = {
        VGA1 = {
          enable = true;
          primary = false;
          mode = "1920x1080";
          position = "0x420";
          gamma = "1.0:0.909:0.909";
          rate = "60.00";
        };
        DP1 = {
          enable = true;
          primary = true;
          mode = "2560x1440";
          position = "1920x240";
          gamma = "1.0:0.909:0.909";
          rate = "59.95";
        };
        DP2 = {
          enable = true;
          primary = false;
          mode = "1920x1080";
          position = "4480x0";
          gamma = "1.0:0.909:0.909";
          rate = "60.00";
          rotate = "left";
        };
      };
    };
  };
}
