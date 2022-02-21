{ self, deploy-rs, nixpkgs, ... }@inputs:

let
  inherit (nixpkgs) lib;
  inherit (lib) attrValues genAttrs mapAttrs';
  genAttrs' = func: values: builtins.listToAttrs (map func values);

  getHostname = path: lib.lists.last (lib.splitString "/" path);
  getConfiguration = path: "${toString ./.}/${path}/configuration.nix";

  hosts = {
    x86_64-linux = [
      "avh/edge-2"
      "bar/cuckoo"
      "bar/nas-1"
      "fsn/k3s-1"
      "fsn/kvm-2"
      "fsn/mail-1"
      "fsn/pine"
      "p13/storj-1"
      "pvl/edge-1"
      "rsn/goat"
      "rsn/hedgehog"
      "rsn/labnuc"
      "rsn/sas"
    ];
    x86_64-darwin = [ ];
  };
in
# This currently segfaults. See https://github.com/NixOS/nix/issues/4893
/* attrValues (
  mapAttrs'
    (system: paths:
      genAttrs'
        (path: {
          name = getHostname path;
          value = {
            # TODO: add builder for darwin if we are evalutating
            # `x86_64-darwin` hosts
            inherit system;
            channelName = "nixpkgs";
            modules = [ (getConfiguration path) ];
          };
        })
        paths
    )
    hosts
) */

(genAttrs hosts.x86_64-linux (
  path: rec {
    system = "x86_64-linux";
    specialArgs = { inherit system; };
    modules = [
      { networking.hostName = lib.mkForce (getHostname path); }
      (getConfiguration path)
    ];
  }
)) // (genAttrs hosts.x86_64-darwin (
  path: rec {
    system = "x86_64-darwin";
    builder = args: inputs.darwin.lib.darwinSystem (removeAttrs args [ "system" ]);
    output = "darwinConfigurations";
    specialArgs = { inherit system; };
    modules = [
      { networking.hostName = lib.mkForce (getHostname path); }
      (getConfiguration path)
    ];
  }
))
