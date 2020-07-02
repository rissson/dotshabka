{ config, lib, pkgs, ... }:

{
  programs.gpg = {
    enable = true;
    settings = {
      throw-keyids = true;
      keyserver = "hkps://keys.openpgp.org";
    };
  };
}
