#!/bin/bash

git config --global credential.helper cache
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMPDIR=/tmp/apply_common_files.$$

if test "${CLONE_USERNAME:-}" = ""; then
    echo "CLONE_USERNAME env is not set"
    exit 1
fi
if test "${CLONE_PASSWORD:-}" = ""; then
    echo "CLONE_PASSWORD env is not set"
    exit 1
fi
if test "${GITHUB_TOKEN:-}" = ""; then
    echo "GITHUB_TOKEN env is not set"
    exit 1
fi

function cleanup {
    rm -Rf "${TMPDIR}"
}

set -eu
trap cleanup EXIT

mkdir -p "${TMPDIR}"
if test "${LIMIT_TO_REPO:-}" != ""; then
    echo "${LIMIT_TO_REPO}" >"${TMPDIR}/repos"
else
    "${DIR}/get_repos.py" metwork-framework >"${TMPDIR}/repos"
fi
for REPO in $(cat "${TMPDIR}/repos"); do
    echo "***** REPO: ${REPO} *****"
    echo ""
    INTEGRATION_LEVEL=$("${DIR}/get_integration_level.py" metwork-framework "${REPO}")
    if test "${INTEGRATION_LEVEL}" = "0"; then
        continue
    fi
    if test "${INTEGRATION_LEVEL}" = "4"; then
        echo "skipping ${REPO} because integration_level>=4"
        continue
    fi
    if test "${INTEGRATION_LEVEL}" = "5"; then
        echo "skipping ${REPO} because integration_level>=4"
        continue
    fi
    cd "${TMPDIR}"
    git clone "https://${CLONE_USERNAME}:${CLONE_PASSWORD}@github.com/metwork-framework/${REPO}.git"
    cd "${REPO}"
    git config user.email "metworkbot@metwork-framework.org"
    git config user.name "metworkbot"
    rm -Rf "${TMPDIR}/common"
    export REPO_HOME="${TMPDIR}/${REPO}"
    TOPICS=$("${DIR}/get_topics.py" metwork-framework "${REPO}")
    export REPO
    export TOPICS
    export INTEGRATION_LEVEL
    renvtpl "${DIR}/../common_files" "${TMPDIR}/common"
    cd "${TMPDIR}/common"
    post_gen_project
    if ! test -f "${TMPDIR}/common/.mergify.yml"; then
        echo "skipping ${REPO} because no .mergify.yml found"
        continue
    fi
    cp -f "${TMPDIR}/common/.mergify.yml" "${TMPDIR}/${REPO}/"
    cd "${TMPDIR}/${REPO}"
    git add -u
    git add --all
    N=$(git diff --cached |wc -l)
    if test "${N}" -gt 0; then
        if test "${DEBUG:-}" = "2"; then
            git status
            git diff --cached
        else
            git commit -m "build: sync common files from github_organization_management repository"
            git push -u origin master
        fi
    else
        echo "=> NO CHANGE"
    fi
    echo ""
    echo ""
done
