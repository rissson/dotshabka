{ lib, config, pkgs, ... }:
let
  colors = import ./colors.nix;
  deepbackground = "#00000000";  # Transparent
  background = colors.black;
  module-text = text: {
    type = "custom/text";
    content = text;
    content-foreground = background;
    content-background = deepbackground;
  };
in
  {
    services.polybar = {
      package = pkgs.polybar.override {
        i3GapsSupport = true;
        alsaSupport = true;
        # iwSupport = true;
        # githubSupport = true;
      };
      enable = true;
      script = "polybar top &";
      config = let
        font-size = "10";
      in {
        "bar/top" = {
        # monitor = "\${env:MONITOR:eDP1}";
        width = "100%";
        height = "25";
        radius = 0;
        border-bottom-size = 0;
        line-size = 2;

        background = deepbackground;

        modules-left = "i3";
        modules-center = "date";
        modules-right = "temperature battery";

        font-0 = "Source Code Pro:size=${font-size}";
        font-1 = "NotoEmoji:scale=10";
        font-2 = "Font Awesome 5 Free Solid:size=${font-size}";
        font-3 = "Font Awesome 5 Brands:size=${font-size}";
        font-4 = "Source Code Pro Regular:size=${font-size}";
        # font-1 = "Font Awesome 5 Free:pixelsize=14;2";
        # font-1 = "Monaco Nerd Font Mono:pixelsize=14;2";
        # font-2 = "Monaco Nerd Font Mono:pixelsize=18;2";

        tray-position = "right";
        tray-padding = 1;
        tray-transparent = true;

      };

      "module/date" = {
        type = "internal/date";
        interval = 1;
        date = "";
        date-alt = " %a %d %b %Y ";
        time = "%H:%M";
        time-alt = "%H:%M:%S";

        label = " %time% %date%";
        label-background = background;
        format-underline = colors.warm;
      };

      "module/arrow->" = module-text "";
      "module/arrow<-" = module-text "";

      "module/temperature" = {
        type = "internal/temperature";
        termal-zone = 0;
        warn-termperature = 40;

        format = "<label>";
        format-warn = " <label-warn>";
        format-warn-underline = colors.warm;

        label = " %temperature-c% ";
        label-background = deepbackground;

        label-warn = " %temperature-c% ";
        label-warn-foreground = colors.warn;
        label-warn-background = deepbackground;
      };

      "module/battery" = {
        type = "internal/battery";
        # Use the following command to list batteries and adapters:
        #   ls -1 /sys/class/power_supply/
        battery = "BAT0";
        adapter = "AC";
        full-at = 100;

        format-full = "<label-full>%";
        label-full = "Full %percentage%";

        format-discharging = "<ramp-capacity> <label-discharging>%";
        label-discharging = "%percentage%";

        ramp-capacity-0 = "";
        ramp-capacity-1 = "";
        ramp-capacity-2 = "";
        ramp-capacity-3 = "";
        ramp-capacity-4 = "";

        format-charching = "<label-charging>";
        label-charging = "%percentage%%⚡";
      };

    };
    extraConfig = ''
      [module/i3]
      type = internal/i3

      fuzzy-match = false
      ; Strip workspace numbers
      strip-wsnumbers = true
      ; Icons:   🎵 🕸 🎶
      ws-icon-0 = 1;🔥
      ws-icon-1 = 2;
      ws-icon-2 = 3;🌐
      ws-icon-3 = 4;4
      ws-icon-4 = 5;🎮
      ws-icon-5 = 6;6
      ws-icon-6 = 7;7
      ws-icon-7 = 8;🖌
      ws-icon-8 = 9;📨
      ws-icon-9 = 10;
      ws-icon-default = 

      format = <label-state> <label-mode>
      index-sort = true
      wrapping-scroll = false

      ; Only show workspaces on the same output as the bar
      pin-workspaces = true

      label-mode-padding = 2
      label-mode-foreground = #000
      label-mode-background = ${colors.warm}

      ; focused = Active workspace on focused monitor
      label-focused = %icon%
      label-focused-foreground = #ffffff
      label-focused-background = ${colors.dark}
      label-focused-underline = ${colors.good}
      label-focused-padding = 1
      ; label-focused-font = 1

      ; unfocused = Inactive workspace on any monitor
      label-unfocused = %icon%
      label-unfocused-background = ${colors.black}
      label-unfocused-underline = ${colors.warm}
      label-unfocused-padding = ''${self.label-focused-padding}
      ; label-unfocused-font = 1

      ; visible = Active workspace on unfocused monitor
      label-visible = %icon%
      label-visible-background = ''${self.label-focused-background}
      label-visible-underline = ''${self.label-focused-underline}
      label-visible-padding = ''${self.label-focused-padding}
      ; label-visible-font = 1

      ; urgent = Workspace with urgency hint set
      label-urgent = %icon%
      label-urgent-foreground = ${colors.black}
      label-urgent-background = ${colors.warn}
      label-urgent-padding = ''${self.label-focused-padding}
      ; label-urgent-font = 1
    '';
  };
}
