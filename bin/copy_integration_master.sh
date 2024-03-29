#!/bin/bash

git config --global credential.helper cache
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMPDIR=/tmp/copy_branch.$$

function cleanup {
    rm -Rf "${TMPDIR}"
}

set -u
set -x
trap cleanup EXIT

mkdir -p "${TMPDIR}"
if test "${LIMIT_TO_REPO}" != ""; then
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
    git reset --hard origin/integration
    "${DIR}/remove_branch_protection.py" metwork-framework "${REPO}" master >/dev/null 2>&1 || true
    git push -u origin -f master
    "${DIR}/restore_branch_protection.py" metwork-framework "${REPO}" master >/dev/null 2>&1 || true
    echo ""
    echo ""
done
