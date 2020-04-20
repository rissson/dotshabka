{
  shabka.home-manager.config = { userName, uid, isAdmin, home, nixosConfig }:
  { lib, ... }:

  with lib;

  {
    imports = [
      <shabka/modules/home>
      ../../../modules/home/default
    ] ++ (optionals (userName == "risson") [
      ../../../modules/home/risson
      ./risson.nix
    ]) ++ (optionals (userName == "diego") [
      ../../../modules/home/diego
      ./diego.nix
    ]);

    shabka.nixosConfig = nixosConfig;
  };
}
