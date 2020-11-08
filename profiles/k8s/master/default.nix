{ config, pkgs, lib, ... }:

let
  nodeIP = (lib.head config.networking.interfaces.ens3.ipv4.addresses).address;
in
{
  imports = [
    ./etcd.nix
  ];

  sops.validateSopsFiles = false;
}
