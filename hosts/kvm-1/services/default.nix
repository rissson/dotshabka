{ pkgs, ... }:

{
  imports = [
    ./gitlab-runners
    #./hercules-ci.nix
    ./libvirt
    ./TheFractalBot.nix
  ];

  services.bitlbee = {
    enable = true;
    plugins = with pkgs; [
      bitlbee-facebook
    ];
  };
}
