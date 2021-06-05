{ self, lib, ... } @ inputs:

let
  inherit (lib) attrValues mapAttrs';

  getHostname = path: lib.lists.last (lib.splitString "/" path);
  getConfiguration = path: "${toString ./.}/${path}/configuration.nix";

  hosts = {

    x86_64-linux = [
      "rsn/goat"
      "rsn/hedgehog"
    ];
    # x86_64-darwin = [ ];
  };

  genAttrs' = func: values: builtins.listToAttrs (map func values);
in
attrValues (
  mapAttrs'
    (system: paths:
      genAttrs'
        (path: {
          name = getHostname path;
          value = {
            inherit system;
            channelName = "nixpkgs";
            modules = [ (getConfiguration path) ];
          };
        })
        paths
    )
    hosts
)




/*
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

(import ./nixos inputs) //
(import ./darwin inputs)*/
