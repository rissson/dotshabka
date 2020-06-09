{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    htop
    iotop
    jq
    killall
    ldns
    minio-client
    ncdu
    tcpdump
    traceroute
    tree
    unzip
    wget
    zip
  ];
}
