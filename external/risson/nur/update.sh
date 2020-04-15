#! /usr/bin/env bash

set -euo pipefail

readonly here="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
readonly shabka_path="$(cd "${here}"/../../../ && pwd)"

exec "${shabka_path}/scripts/update-external.sh" rissson nur-packages master "${here}/version.json"
