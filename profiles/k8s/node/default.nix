{ nixpkgs, lib, ... }:

{
  boot.kernelPackages = lib.mkForce nixpkgs.linuxPackages_latest;
}
