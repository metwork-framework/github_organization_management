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

if test "${TARGET_BRANCH:-}" = ""; then
    echo "TARGET_BRANCH is mandatory"
    exit 1
fi

mkdir -p "${TMPDIR}"
if test "${LIMIT_TO_REPO:-}" != ""; then
    echo "${LIMIT_TO_REPO}" >"${TMPDIR}/repos"
else
    "${DIR}/list_repos.py" --topic=integration-level-4 >"${TMPDIR}/repos"
    "${DIR}/list_repos.py" --topic=integration-level-5 >>"${TMPDIR}/repos"
fi

for REPO in $(cat "${TMPDIR}/repos"); do
    echo "***** REPO: ${REPO} *****"
    echo ""
    cd "${TMPDIR}"
    git clone "https://${USERNAME}:${PASSWORD}@github.com/metwork-framework/${REPO}.git"
    cd "${REPO}"
    git config user.email "metworkbot@metwork-framework.org"
    git config user.name "metworkbot"
    git checkout "${TARGET_BRANCH}"
    "${DIR}/remove_branch_protection.py" metwork-framework "${REPO}" "${TARGET_BRANCH}" >/dev/null 2>&1 || true
    git push -u origin -d "${TARGET_BRANCH}"
    echo ""
    echo ""
done
