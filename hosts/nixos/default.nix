{ self, deploy-rs, lib, ... } @ inputs:

let
  x86_64-linux = [
    "rsn/goat"
    "rsn/hedgehog"
  ];
in
{
  ###
  # x86_64-linux
  ###

  "rsn/hedgehog" = {
    channelName = "nixpkgs"; # the default channel to follow
    system = "x86_64-linux";
    modules = [
      "${self}/hosts/rsn/hedgehog/configuration.nix"
      { networking.hostName = lib.mkForce "hedgehog"; }
    ];
  };

  "rsn/goat" = {
    channelName = "nixpkgs"; # the default channel to follow
    system = "x86_64-linux";
    modules = [
      "${self}/hosts/rsn/goat/configuration.nix"
      { networking.hostName = lib.mkForce "goat"; }
    ];
  };
}
