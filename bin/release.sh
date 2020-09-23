#!/bin/bash

git config --global credential.helper cache
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMPDIR=/tmp/release.$$

function cleanup {
    rm -Rf "${TMPDIR}"
}

set -eu
trap cleanup EXIT

if test "${BRANCH:-}" = ""; then
    echo "ERROR: you must specify the BRANCH (example: release_0.9)"
    exit 1
fi
MAJORMINOR=$(echo "${BRANCH}" |sed 's/release_//g')

mkdir -p "${TMPDIR}"
if test "${LIMIT_TO_REPO:-}" != ""; then
    echo "${LIMIT_TO_REPO}" >"${TMPDIR}/repos"
else
    "${DIR}/get_repos.py" --topic=integration-level-5 metwork-framework >>"${TMPDIR}/repos"
fi

for REPO in $(cat "${TMPDIR}/repos"); do
    echo "***** REPO: ${REPO} *****"
    echo ""
    cd "${TMPDIR}"
    git clone "https://${USERNAME}:${PASSWORD}@github.com/metwork-framework/${REPO}.git"
    cd "${REPO}"
    git config user.email "metworkbot@metwork-framework.org"
    git config user.name "metworkbot"
    git checkout "${BRANCH}"
    PATCH=0
    while test 1 -eq 1; do
        CANDIDATE="v${MAJORMINOR}.${PATCH}"
        echo "testing ${CANDIDATE}..."
        N=$(git tag -l "v${MAJORMINOR}.*" |grep "${CANDIDATE}" |wc -l)
        if test ${N} -gt 0; then
            echo "already exist"
            PATCH=$(expr ${PATCH} + 1)
            continue
        fi
        echo "ok => let's tag: ${CANDIDATE}"
        git tag "${CANDIDATE}"
        if test "${DEBUG:-}" = "0"; then
          git push origin "${CANDIDATE}"
        else
          echo "DEBUG mode: we don't push the tag"
        fi
        break
    done
    echo ""
    echo ""
done
