{ config, lib, pkgs, ... }:

{
  programs.gpg = {
    enable = true;
    settings = {
      throw-keyids = true;
      keyserver = "hkp://pool.sks-keyservers.net";
    };
  };
}
