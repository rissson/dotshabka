{ mode, config, lib, ... }:

with lib;

let
  cfg = config.networking;
in
{
  options = {
    networking = {
      fqdn = mkOption {
        default = "";
        type = types.str;
        description = "Fully Qualified Name.";
      };
    };
  };

  config = mkMerge [
    (optionalAttrs (mode == "NixOS") {
      networking.fqdn = mkDefault "${config.networking.hostName}.${config.networking.domain}";
    })
  ];
}
