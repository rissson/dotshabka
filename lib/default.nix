{ lib }:

{
  overlaysToPkgs = import ./overlays-to-pkgs.nix { inherit lib; };
  pathsToImportedAttrs = import ./paths-to-imported-attrs.nix { inherit lib; };
}
