{ mode, config, lib, ... }:

with lib;

let
  cfg = config.lama-corp.settings.keyboard;

  layoutModule = types.submodule ({ config, ... }: {
    options = {
      layout = mkOption {
        type = types.str;
        default = "us";
        example = "fr";
        description = "Keyboard layout";
      };

      variant = mkOption {
        type = types.str;
        default = "";
        example = "colemak";
        description = "Keyboard variant";
      };

      keyMap = mkOption {
        type = types.str;
        example = "us";
        description = ''
          The keyboard mapping table for the virtual consoles. The default is
          the layout associated with the keyMap but you may need to change this
          depending on your keyboard variant.
        '';
      };
    };

    config = {
      keyMap = mkDefault config.layout;
    };
  });
in
{
  options = {
    lama-corp.settings.keyboard = {
      layouts = mkOption {
        type = with types; listOf layoutModule;
        description = ''
          Keyboard layouts to use for consoles and Xorg server. The first
          layout of this list will be used as the default layout.
        '';
      };

      defaultLayout = mkOption {
        type = layoutModule;
        default = builtins.head cfg.layouts;
        internal = true;
        description = ''
          Default keyboard layout.
        '';
      };

      enableAtBoot = recursiveUpdate (mkEnableOption ''
        Enable setting keyboard layout as early as possible (in initrd).
      '') { default = true; };
    };
  };

  config = mkMerge [
    {
      assertions = [
        {
          assertion = cfg.layouts != [];
          message = "lama-corp.keyboard.layouts cannot be empty";
        }
      ];
    }

    (optionalAttrs (mode == "NixOS") {
      console = {
        inherit (cfg.defaultLayout) keyMap;
        earlySetup = cfg.enableAtBoot;
      };

      services.xserver = {
        layout = concatMapStringsSep "," (l: l.layout) cfg.layouts;
        xkbVariant = concatMapStringsSep "," (l: l.variant) cfg.layouts;
      };
    })

    (optionalAttrs (mode == "home-manager") {
      home.keyboard = {
        layout = concatMapStringsSep "," (l: l.layout) cfg.layouts;
        variant = concatMapStringsSep "," (l: l.variant) cfg.layouts;
      };
    })
  ];
}
