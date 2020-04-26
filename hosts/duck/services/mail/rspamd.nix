{ confiug, lib, ... }:

with lib;

{
  services.rspamd = mkIf config.services.postfix.enable {
    postfix = {
      enable = true;
      config = {
      };
    };
  };
}
