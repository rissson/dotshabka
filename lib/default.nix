final: prev:
{
  overlaysToPkgs = import ./overlays-to-pkgs.nix { lib = prev; };
  pathsToImportedAttrs = import ./paths-to-imported-attrs.nix { lib = prev; };
}
