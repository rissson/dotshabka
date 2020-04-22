{
  shabka.home-manager.config = { userName, uid, isAdmin, home, nixosConfig }:
  { lib, ... }:

  with lib;

  {
    imports = [
      <shabka/modules/home>
      <dotshabka/modules/home>
      <dotshabka/modules/home/server>
    ] ++ (optionals (userName == "risson") [
      <dotshabka/modules/home/risson>
      <dotshabka/modules/home/risson/server>
      ./risson.nix
    ]) ++ (optionals (userName == "diego") [
      <dotshabka/modules/home/diego>
      <dotshabka/modules/home/diego/server>
      ./diego.nix
    ]);

    shabka.nixosConfig = nixosConfig;
  };
}
