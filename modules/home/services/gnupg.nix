{ config, pkgs, lib, ... }:

{
  shabka.gnupg.defaultCacheTtl = 1800;
  shabka.gnupg.defaultCacheTtlSsh = 1800;
}