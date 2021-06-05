{ inputs, mode, config, pkgs, lib, ... }:

{
  config = lib.mkMerge [
    (lib.optionalAttrs (mode == "NixOS") {
      system.activationScripts.setup-secrets =
        let
          sops-install-secrets = inputs.sops-nix.packages.x86_64-linux.sops-install-secrets;
          manifest = builtins.toFile "manifest.json" (builtins.toJSON {
            secrets = builtins.attrValues config.sops.secrets;
            # Does this need to be configurable?
            secretsMountPoint = "/run/secrets.d";
            symlinkPath = "/run/secrets";
            inherit (config.sops) gnupgHome sshKeyPaths;
          });

          checkedManifest = pkgs.runCommandNoCC "checked-manifest.json" {
            nativeBuildInputs = [ sops-install-secrets ];
          } ''
            sops-install-secrets -check-mode=${if config.sops.validateSopsFiles then "sopsfile" else "manifest"} ${manifest}
            cp ${manifest} $out
          '';
        in
        lib.mkForce (lib.stringAfter [ "users" "groups" ] ''
          echo setting up secrets...
          export PATH=$PATH:${pkgs.gnupg}/bin:${pkgs.gnupg}/sbin
          SOPS_GPG_EXEC=${pkgs.gnupg}/bin/gpg ${sops-install-secrets}/bin/sops-install-secrets ${checkedManifest}
        '');
        })
  ];
}
