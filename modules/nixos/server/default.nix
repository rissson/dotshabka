with import <shabka/util>;

{
  imports = recImport ./.;

  services.netdata.enable = true;
}
