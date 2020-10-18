{ soxincfg }:
{ nixosConfig, ... }:

{
  imports = [ soxincfg.homeModules.shabka ];

  shabka.nixosConfig = nixosConfig;
}
