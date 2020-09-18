#!/bin/bash

set -x

git config --global credential.helper cache
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMPDIR=/tmp/copy_branch.$$

function cleanup {
    rm -Rf "${TMPDIR}"
}

set -eu
trap cleanup EXIT

if test "${SOURCE_BRANCH:-}" = ""; then
    echo "SOURCE_BRANCH is mandatory"
    exit 1
fi
if test "${TARGET_BRANCH:-}" = ""; then
    echo "TARGET_BRANCH is mandatory"
    exit 1
fi

mkdir -p "${TMPDIR}"
if test "${LIMIT_TO_REPO:-}" != ""; then
    echo "${LIMIT_TO_REPO}" >"${TMPDIR}/repos"
else
    "${DIR}/get_repos.py" --topic=integration-level-4 metwork-framework >"${TMPDIR}/repos"
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
    git checkout "${SOURCE_BRANCH}"
    if test "${REMOVE_BRANCH_PROTECTION:-}" = "1"; then
        "${DIR}/remove_branch_protection.py" metwork-framework "${REPO}" "${TARGET_BRANCH}" || true
    fi
    git push -u origin -f "${SOURCE_BRANCH}:${TARGET_BRANCH}"
    echo ""
    echo ""
done
