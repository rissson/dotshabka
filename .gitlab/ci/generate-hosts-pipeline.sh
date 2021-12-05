#!/usr/bin/env bash

set -euo pipefail

source "${CI_PROJECT_DIR}/.gitlab/ci/utils.sh"

echoInfo "Getting ready..."

hostS_DIFF_DIR="${DIFF_DIR}/hosts"
mkdir -p "${hostS_DIFF_DIR}"

print_defaults

function getHostDrvPath() {
  repo="${1}"
  host="${2}"

  path="${repo}#nixosConfigurations.${host}.config.system.build.toplevel.drvPath"

  echo "${path}"
}

function didHostChange() {
  host="${1}"
  diffDir="${hostS_DIFF_DIR}/${host}"
  currentHostDrvPath="$(getHostDrvPath "${CI_PROJECT_DIR}" "${host}")"
  previousHostDrvPath="$(getHostDrvPath "git+${CI_PROJECT_URL}?ref=${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}" "${host}")"

  currentDrv="$(nix eval --raw "${currentHostDrvPath}")"
  previousDrv="$(nix eval --raw "${previousHostDrvPath}")" || return 0

  # We allow 54 lines of differences, which is the amount that changes when
  # only the commit SHA changes.
  diffDrv "${previousDrv}" "${currentDrv}" "${diffDir}" 88
}

echoInfo "Listing all hosts..."
hosts="$(nix_run list-hosts | xargs)"
echoInfo "Hosts found: ${hosts}"

changedHosts=""

echoInfo "Starting pipeline generation..."

if [ -z "${CI_MERGE_REQUEST_IID:-}" ] || [ -n "${ALL_HOSTS:-}" ]; then
  echoWarn "Pipeline is not attached to a merge request."
  echoWarn "All hosts will be rebuilt."
  changedHosts="${hosts}"
else
  echoWarn "Pipeline is attached to a merge request."
  echoWarn "Checking what hosts we should rebuild..."
  for host in ${hosts}; do
    echoInfo "Checking if host ${host} changed..."
    if didHostChange "${host}"; then
      echoInfo "Host ${host} changed. Queued for rebuilding."
      changedHosts="${changedHosts:-} ${host}"
    else
      echoInfo "Host ${host} did not change. Not rebuilding."
    fi
  done
fi

echoWarn "Hosts to be rebuilt are: ${changedHosts}"

echoInfo "Generating pipeline..."

for host in ${changedHosts}; do
echoInfo "Generating jobs for host ${host}..."
cat <<EOF
${host}:build:
  extends:
    - .build
  script:
    - buildExpression=".#nixosConfigurations.${host}.config.system.build.toplevel"
    - nix -L build "\$buildExpression"
    - nix store sign --recursive --key-file "\${NIX_CACHE_PRIV_KEY_FILE}" "\$buildExpression"
    - cat "\${AWS_NIX_CACHE_CREDENTIALS_FILE}" > ~/.aws/credentials
    - nix copy --to "s3://\${AWS_NIX_CACHE_BUCKET}?scheme=https&endpoint=\${AWS_NIX_CACHE_ENDPOINT}" "\$buildExpression"
EOF
done

echoSuccess "All done!"
