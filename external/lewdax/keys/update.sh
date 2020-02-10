#! /usr/bin/env bash

set -euo pipefail

readonly here="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
readonly shabka_path="$(cd "${here}"/../../../ && pwd)"

echo "{\"url\":\"https://gitlab.com/hanewaifu.keys\",\"sha256\":\"$(nix-prefetch-url https://gitlab.com/hanewaifu.keys)\"}" > "${here}/version.json"
