{ ... }:

{
  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "*-*-* 03:26:17 UTC";
      options = "--delete-older-than 10d";
    };
  };
}
