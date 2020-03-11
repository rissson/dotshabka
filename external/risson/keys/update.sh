#! /usr/bin/env bash

set -euo pipefail

readonly here="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
readonly shabka_path="$(cd "${here}"/../../../ && pwd)"

echo "{\"url\":\"https://risson.space/ssh.keys\",\"sha256\":\"$(nix-prefetch-url https://risson.space/ssh.keys)\"}" > "${here}/version.json"
