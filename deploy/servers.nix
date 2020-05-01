{
  network = {
    description = "Lama Corp. servers";
  };

  "duck.srv.fsn.lama-corp.space" = { ... }: {
    imports = [
      "${<dotshabka>}/hosts/duck/configuration.nix"
    ];
  };
}
