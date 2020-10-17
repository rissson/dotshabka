# Convert a list to file paths to attribute set
# that has the filenames stripped of nix extension as keys
# and imported content of the file as value.

{ lib }:

let
  # Generate an attribute set by mapping a function over a list of values.
  genAttrs' = values: f: builtins.listToAttrs (map f values);
in
paths:
  genAttrs' paths (path: {
    name = lib.removeSuffix ".nix" (baseNameOf path);
    value = import path;
  })
