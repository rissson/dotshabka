{ config, pkgs, lib, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_12;
    ensureDatabases = [ "mailman_web" ];
    ensureUsers = [{
      name = "mailman_web";
      ensurePermissions = {
        "DATABASE mailman_web" = "ALL PRIVILEGES";
      };
    }];
  };

  services.mailman = {
    enable = true;
    serve.enable = true;
    hyperkitty.enable = true;
    webHosts = [ "lists.lama-corp.space" ];
    siteOwner = "postmaster@lama-corp.space";
    webSettings = {
      MAILMAN_ARCHIVER_FROM = [ "127.0.0.1" "::1" ];
      DATABASES = {
        default = {
          ENGINE = "django.db.backends.postgresql";
          NAME = "mailman_web";
          USER = "mailman_web";
          HOST = "localhost";
        };
      };
    };
  };

  environment.etc."mailman3/settings.py".text = lib.mkAfter ''
    with open("${config.sops.secrets.mailman_postgresql_password.path}", mode="r") as file:
      postgresql_password = file.read()
    DATABASES["default"]["PASSWORD"] = postgresql_password
  '';

  services.nginx.virtualHosts."lists.lama-corp.space" = {
    enableACME = true;
    addSSL = true;
  };
  users.users.mailman-web.extraGroups = [ "keys" ];

  sops.secrets.mailman_postgresql_password = {
    owner = "mailman-web";
    sopsFile = ./mailman.yml;
  };
}
