{ lib, config, pkgs, ... }:
{
  wayland.windowManager.sway =
    let 
      wallpaper_cmd = "killall swaybg || swaybg -i ~/Pictures/fractals -m fill";
      nosid = "--no-startup-id";
    in {
    enable = true;
    config = {
      modifier = "Mod4";

      keybindings = let
        mod = "Mod4";
      in lib.mkOptionDefault {
        # Vm switch focus
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus up";
        "${mod}+k" = "focus down";
        "${mod}+l" = "focus right";
        # Vim move containers
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move up";
        "${mod}+Shift+k" = "move down";
        "${mod}+Shift+l" = "move right";
        # Other way to make horizontal splits since Mod4+h is already focus left
        "${mod}+Shift+v" = "split h";
        # Toggle sticky window
        "${mod}+Shift+s" = "sticky toggle";
        # Show notification center
        "${mod}+Shift+Return" = "exec kill -USR1 $(pidof deadd-notification-center)";
        # Lock screen
        "${mod}+Shift+x" = "exec i3lock -c ffa500";
        # Audio keys
        "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10%";
        "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10%";
        "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        # Brightness keys
        "XF86MonBrightnessUp" = "exec brightnessctl s 10%+";
        "XF86MonBrightnessDown" = "exec brightnessctl s 10%-";
        # Screenshot
        "Print" = "exec spectacle --fullscreen";
        "Shift+Print" = "exec spectacle --windowundercursor";
        "Mod4+Print" = "exec spectacle --region";
        # Randomize background
        "${mod}+shift+b" = "exec ${nosid} ${wallpaper_cmd}";
      };

      startup = [ 
        { command = "${wallpaper_cmd}"; always = true; }
        # Software
        { command = "terminator -x htop"; }
        { command = "firefox"; }
        { command = "telegram"; }
        { command = "spotify"; }
      ];

      window = {
        # border = 2;
        hideEdgeBorders = "smart";
        titlebar = false;
        # workspaceAutoBackAndForth = true;  # when i'll switch to a new version of home-manager
        commands = [
          {
            criteria = { class = "Spotify"; };
            command = "move to workspace 10";
          }
        ];
      };

      gaps = {
        inner = 12;
      };

      focus = {
        newWindow = "focus";
      };

      assigns = {
        "3" = [
          { class = "Firefox"; }
        ];
        "7" = [
          { class = "Steam"; }
        ];
        "9" = [
          { class = "Discord"; }
          { class = "Slack"; }
          { class = "Thunderbird"; }
          { class = "Rambox"; }
          { class = "TelegramDesktop"; }
        ];
      };

      floating = {
        modifier = "Mod4";
        titlebar = false;
        criteria = [
          { title = "win0"; }  # Jetbrains splash screen
          { class = "zoom"; }
          { title = "Brocoli"; }
          { title = "The Casta Way"; }
          { class = "MATLAB *"; }
        ];
      };

      colors = {
        focused = {
          border = "#FFA500";
          background = "#2C8268";
          text = "#FFFFFF";
          indicator = "#FFA500";
          childBorder = "#ffa500";
        };
        focusedInactive = {
          border = "#5F676A ";
          background = "#5F676A ";
          text = "#FFFFFF ";
          indicator = "#484E50 ";
          childBorder = "#5F676A";
        };
        unfocused = {
          border = "#222222";
          background = "#222222";
          text = "#888888";
          indicator = "#292D2E";
          childBorder = "#222222";
        };
        urgent = {
          border = "#FFA500";
          background = "#FFA500";
          text = "#FFFFFF";
          indicator = "#000042";
          childBorder = "#000042";
        };
        placeholder = {
          border = "#000000";
          background = "#0C0C0C";
          text = "#FFFFFF";
          indicator = "#000000 ";
          childBorder = "#0C0C0C";
        };
        background = "#696969";
      };
    };

    extraConfig = ''
      workspace_auto_back_and_forth yes


      set $hue source ~/.envrc && hue.py --key $HUE_KEY
      mode "shortcuts" {
        # Controling lights
        bindsym t exec --no-startup-id $hue set toggle
        bindsym o exec --no-startup-id $hue set off
        bindsym i exec --no-startup-id $hue set on
        bindsym d exec --no-startup-id $hue set dim
        bindsym b exec --no-startup-id $hue set bright

        bindsym a exec --no-startup-id $hue set algebre
        bindsym g exec --no-startup-id $hue set geo
        bindsym p exec --no-startup-id $hue set info
        bindsym r exec --no-startup-id $hue set analyse

        bindsym 1 exec --no-startup-id $hue put -x ff0000 -1 all
        bindsym 2 exec --no-startup-id $hue put -x ffa500 -1 all
        bindsym 3 exec --no-startup-id $hue put -x ffff00 -1 all
        bindsym 4 exec --no-startup-id $hue put -x 80ff00 -1 all
        bindsym 5 exec --no-startup-id $hue put -x 00ff00 -1 all
        bindsym 6 exec --no-startup-id $hue put -x 00ff80 -1 all
        bindsym 7 exec --no-startup-id $hue put -x 00ffff -1 all
        bindsym 8 exec --no-startup-id $hue put -x 0080ff -1 all
        bindsym 9 exec --no-startup-id $hue put -x 0000ff -1 all
        bindsym 0 exec --no-startup-id $hue put -x 8000ff -1 all
        bindsym minus exec --no-startup-id $hue put -x ff00ff -1 all

        # Open apps
        bindsym f exec --no-startup-id firefox
        bindsym s exec --no-startup-id spotify
        bindsym v exec --no-startup-id i3-sensible-terminal -e alsamixer

        # Controling music
        bindsym F1 exec --no-startup-id playerctl previous
        bindsym F2 exec --no-startup-id playerctl play-pause
        bindsym F3 exec --no-startup-id playerctl next

        # back to normal: Escape
        bindcode 9 mode "default"
      }
      bindcode 9 mode "shortcuts"
    '';
  };
}
