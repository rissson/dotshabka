{
  shabka.home-manager.config = { userName, uid, isAdmin, home, nixosConfig }:
    { lib, ... }:

    with lib;

    {
      imports = [
        <shabka/modules/home>
      ] ++ (optionals (userName == "risson") [
        <dotshabka/modules/risson>
        ./risson.nix
      ]) ++ (optionals (userName == "diego") [
        <dotshabka/modules/diego>
        ./diego.nix
      ]);

      shabka.nixosConfig = nixosConfig;
    };
}
