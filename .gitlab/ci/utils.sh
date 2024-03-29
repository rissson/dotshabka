DIFF_DIR="${CI_PROJECT_DIR}/diffs"

echoErr() { >&2 echo -e "\e[1;31m[ERR] ${*}\e[0m" ; }
echoWarn() { >&2 echo -e "\e[1;33m[WARN] ${*}\e[0m" ; }
echoInfo() { >&2 echo -e "\e[1;34m[INFO] ${*}\e[0m" ; }
echoSuccess() { >&2 echo -e "\e[1;32m[SUCCESS] ${*}\e[0m" ; }

function print_defaults() {
echoInfo "Printing some default stuff..."
cat <<EOF
---

include:
  - template: Workflows/MergeRequest-Pipelines.gitlab-ci.yml
  - local: .gitlab/ci/templates.yml

dummy:
  extends: .misc
  tags: []
  script:
    - echo I am only here so the pipeline does not fail when nothing needs rebuilding.
EOF
}

function nix_run() {
  app="${1}"
  shift 1
  nix run "${CI_PROJECT_DIR}#${app}" -- "${@}"
}

function nix_diff() {
  nix_run nix-diff --line-oriented "${@}"
}

function diffDrv() {
  drvSrc="${1}"
  drvDst="${2}"
  diffDir="${3}"
  allowedDifferences="${4:-0}"

  mkdir -p "${diffDir}"

  # We run multiple times to get color in output. nix-diff is pretty
  # inexpensive so let's not care too much about this
  nix_diff "${drvSrc}" "${drvDst}" > "${diffDir}/diff"
  nix_diff --environment "${drvSrc}" "${drvDst}" > "${diffDir}/diff.env"

  if [ "$(wc -l < "${diffDir}/diff")" -gt "${allowedDifferences}" ]; then
    nix_diff --color always "${drvSrc}" "${drvDst}" >&2
    return 0
  else
    return 1
  fi
}
