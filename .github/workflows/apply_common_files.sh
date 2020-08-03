#!/bin/bash

git config --global credential.helper cache
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMPDIR=/tmp/apply_common_files.$$

function cleanup {
    rm -Rf "${TMPDIR}"
}

set -eu
trap cleanup EXIT

mkdir -p "${TMPDIR}"
if test "${LIMIT_TO_REPO}" != ""; then
    echo "${LIMIT_TO_REPO}" >"${TMPDIR}/repos"
else
    "${DIR}/../../bin/get_repos.py" --topic=integration-level-5 metwork-framework >"${TMPDIR}/repos"
fi
for REPO in $(cat "${TMPDIR}/repos"); do
    echo "***** REPO: ${REPO} *****"
    echo ""
    cd "${TMPDIR}"
    git clone "https://${USERNAME}:${PASSWORD}@github.com/metwork-framework/${REPO}.git"
    cd "${REPO}"
    git config user.email "metworkbot@metwork-framework.org"
    git config user.name "metworkbot"
    git checkout -b common_files_force
    rm -Rf "${TMPDIR}/common"
    export REPO_HOME="${TMPDIR}/${REPO}"
    TOPICS=$("${DIR}/../../bin/get_topics.py" metwork-framework "${REPO}")
    INTEGRATION_LEVEL=$("${DIR}/../../bin/get_integration_level.py" metwork-framework "${REPO}")
    export REPO
    export TOPICS
    export INTEGRATION_LEVEL
    renvtpl "${DIR}/../../common_files" "${TMPDIR}/common"
    cd "${TMPDIR}/common"
    post_gen_project
    shopt -s dotglob
    rsync -av "${TMPDIR}/common/" "${TMPDIR}/${REPO}/"
    cd "${TMPDIR}/${REPO}"
    find . -type f -name "*.forcedelete" |sed 's/\.forcedelete$//g' |xargs rm -rf
    find . -type f -name "*.forcedelete" -exec rm -f {} \;
    git add -u
    git add --all
    N=$(git diff --cached |wc -l)
    if test "${N}" -gt 0; then
        if test "${DEBUG}" = "1"; then
            git status
            git diff --cached
        else
            git commit -m "build: sync common files from github_organization_management repository"
            git push -u origin -f common_files_force
            "${DIR}/../../bin/create_pr.py" --title "WIP: just a test" --body "" --base=integration metwork-framework "${REPO}" common_files_force
        fi
    fi
    echo ""
    echo ""
    exit 0
done
