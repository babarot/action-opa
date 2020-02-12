#!/bin/bash

BASE="${INPUT_PATH}"
COVERAGE="${INPUT_COVERAGE%%%}" # trim % (e.g. 90% -> 90)
FILES=( "${INPUT_FILES}" )

run_opa() {
  local -a targets
  targets=( $(find ${BASE} -name '*.rego') )

  if (( ${#FILES[@]} > 0 )); then
    targets=( "${FILES[@]}" )
  fi

  local error=false

  local rego
  for rego in ${targets[@]}
  do
    # target is only .rego file
    if [[ ${rego} != *.rego ]]; then
      continue
    fi

    # target is only .rego file
    if [[ ${rego} =~ _test.rego$ ]]; then
      continue
    fi

    rego_test="${rego%.rego}_test.rego"
    if [[ ! -f ${rego_test} ]]; then
      echo "[ERROR] ${rego}: test file not found" >&2
      error=true
      continue
    fi

    echo "[INFO] Testing for ${rego}..."
    opa test ${rego} ${rego_test} || error=true

    echo "[INFO] Checking test coverage for ${rego}..."
    local coverage
    coverage="$(opa test --coverage --format=json ${rego} ${rego_test} | jq .coverage 2>/dev/null)"

    if (( ${coverage%.*} > ${COVERAGE} )); then
      echo "PASS: coverage ${coverage}%"
    else
      echo "[ERROR] current test coverage ${coverage}%: must to be ${COVERAGE}.0% or greater" >&2
      error=true
      continue
    fi
  done

  if ${error}; then
    return 1
  fi
}

main() {
  run_opa "$@" | tee -a result
  result="$(cat result)"
  # https://github.community/t5/GitHub-Actions/set-output-Truncates-Multiline-Strings/td-p/37870
  echo "::set-output name=result::${result//$'\n'/'%0A'}"
}

set -o pipefail

main "$@"
exit $?
