{
  network = {
    description = "Lama Corp. servers";
  };

  "ldap-1.duck.srv.fsn.lama-corp.space" = { ... }: {
    imports = [
      "${<dotshabka>}/hosts/ldap-1/configuration.nix"
    ];
  };

  "mail-1.duck.srv.fsn.lama-corp.space" = { ... }: {
    imports = [
      "${<dotshabka>}/hosts/mail-1/configuration.nix"
    ];
  };

  "reverse-1.duck.srv.fsn.lama-corp.space" = { ... }: {
    imports = [
      "${<dotshabka>}/hosts/reverse-1/configuration.nix"
    ];
  };
}
