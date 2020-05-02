{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    htop
    iotop
    ldns
    ncdu
    tree
    wget
  ];
}
