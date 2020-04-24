{ confiug, lib, ... }:

with lib;

{
  services.rspamd = mkIf config.services.postfix.enable {
    postfix = {
      enable = true;
      config = {
        milter_protocol = "6";
        milter_default_action = "accept";
        smtpd_milters = "unix:/run/rspamd/rspamd-milter.sock";
        milter_mail_macros = "i {mail_addr} {client_addr} {client_name} {auth_authen}";
      };
    };
  };
}
