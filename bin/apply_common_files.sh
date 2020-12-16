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
    "${DIR}/list_repos.py" >"${TMPDIR}/repos"
fi
for REPO in $(cat "${TMPDIR}/repos"); do
    echo "***** REPO: ${REPO} *****"
    echo ""
    INTEGRATION_LEVEL=$("${DIR}/get_integration_level.py" metwork-framework "${REPO}")
    if test "${INTEGRATION_LEVEL}" = "0"; then
        continue
    fi
    cd "${TMPDIR}"
    git clone "https://${CLONE_USERNAME}:${CLONE_PASSWORD}@github.com/metwork-framework/${REPO}.git"
    cd "${REPO}"
    git config user.email "metworkbot@metwork-framework.org"
    git config user.name "metworkbot"
    BASE=master
    if test "${INTEGRATION_LEVEL}" = "4" -o "${INTEGRATION_LEVEL}" = "5"; then
        BASE=integration
    fi
    if test "${BASE}" != "master"; then
        git checkout "${BASE}"
    fi
    git checkout -b common_files_force
    rm -Rf "${TMPDIR}/common"
    export REPO_HOME="${TMPDIR}/${REPO}"
    TOPICS=$("${DIR}/get_topics.py" metwork-framework "${REPO}")
    export REPO
    export TOPICS
    export INTEGRATION_LEVEL
    renvtpl "${DIR}/../common_files" "${TMPDIR}/common"
    if test "${INTEGRATION_LEVEL}" != "4" -a "${INTEGRATION_LEVEL}" != "5"; then
        # we remove mergify.yml files because mergify do not merge PRs when
        # its configuration is modified by the current PR
        # (so we have a dedicated action for that)
        # note: not necessary for repos with integration branches
        # because mergify configuration is used in master branch
        rm -f "${TMPDIR}/common/mergify.yml"
        rm -f "${TMPDIR}/common/mergify.yml.rename"
    fi
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
        if test "${DEBUG:-}" = "2"; then
            git status
            git diff --cached
        else
            if test "${DEBUG:-}" = "1"; then
                TITLE="[WIP] common files sync from github_organization_management repo"
            else
                TITLE="build: common files sync from github_organization_management repo"
            fi
            git commit -m "build: sync common files from github_organization_management repository"
            git push -u origin -f common_files_force
            "${DIR}/create_pr.py" --title "${TITLE}" --body "" --base=${BASE} metwork-framework "${REPO}" common_files_force
        fi
    else
        echo "=> NO CHANGE"
    fi
    echo ""
    echo ""
done
