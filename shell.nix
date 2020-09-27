{ pkgs ? import <nixpkgs> { } }:

let
  configs = "${toString ./.}#nixosConfigurations";
  build = "config.system.build";

  rebuild = pkgs.writeShellScriptBin "rebuild" ''
    if [[ -z $1 ]]; then
      echo "Usage: $(basename $0) host {build|switch|boot|test}"
      exit 1
    fi
    readonly host="$1"; shift
    if [[ -z $1 ]]; then
      echo "Usage: $(basename $0) host {build|switch|boot|test}"
      exit 1
    fi
    readonly action="$1"; shift
    if [[ "$action" == "build" ]]; then
      nix build "${configs}.$host.${build}.toplevel" "''${@}"
      exit $?
    fi
    sudo -E nix shell -vv "${configs}.$host.${build}.toplevel" -c switch-to-configuration "$action" "''${@}"
  '';
in
pkgs.mkShell {
  name = "soxincfg";
  nativeBuildInputs = with pkgs; [
    git
    nixfmt
    nixFlakes
    rebuild
  ];

  shellHook = ''
    PATH=${
      pkgs.writeShellScriptBin "nix" ''
        ${pkgs.nixFlakes}/bin/nix --option experimental-features "nix-command flakes ca-references" "$@"
      ''
    }/bin:$PATH
    export DOTSHABKA_PATH="$(pwd)"
  '';

  # Export the location of the SSL CA bundle
  SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
}
