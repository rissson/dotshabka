{ stdenvNoCC }:

let
  mkExternal = { name, revision, src, patches }:
    stdenvNoCC.mkDerivation {
      inherit src patches;
      name = "${name}-${revision}";
      preferLocalBuild = true;

      buildPhase = ''
        echo -n "${revision}" > .git-revision
      '';

      installPhase = ''
        cp -r . $out
      '';

      fixupPhase = ":";
    };
in {
  inherit mkExternal;

  risson = import ./risson { inherit mkExternal; };
}
