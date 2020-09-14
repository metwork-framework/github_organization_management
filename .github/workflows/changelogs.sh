#!/bin/bash

git config --global credential.helper cache
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMPDIR=/tmp/copy_branch.$$

function cleanup {
    rm -Rf "${TMPDIR}"
}

set -eu
trap cleanup EXIT

mkdir -p "${TMPDIR}"
if test "${LIMIT_TO_REPO}" != ""; then
    echo "${LIMIT_TO_REPO}" >"${TMPDIR}/repos"
else
    "${DIR}/../../bin/get_repos.py" --topic=integration-level-3 metwork-framework >"${TMPDIR}/repos"
fi
for REPO in $(cat "${TMPDIR}/repos"); do
    echo "***** REPO: ${REPO} *****"
    echo ""
    cd "${TMPDIR}"
    git clone "https://${USERNAME}:${PASSWORD}@github.com/metwork-framework/${REPO}.git"
    cd "${REPO}"
    git checkout -b changelog_update
    export TITLE=CHANGELOG
    export REV=master
    export EXCLUDE=nothing
    export INCLUDE=master
    export TAG_FILTER="v*"
    auto-changelog --template-dir="${DIR}/../../changelog_templates" --title="${TITLE}" --rev="${REV}" --exclude-branches="${EXCLUDE}" --include-branches="${INCLUDE}" --tag-filter="${TAG_FILTER}" --output=./CHANGELOG.md
    git add -u
    git add --all
    N=$(git diff --cached |wc -l)
    if test "${N}" -gt 0; then
        if test "${DEBUG:-}" = "2"; then
            git status
            git diff --cached
        else
            if test "${DEBUG:-}" = "1"; then
                TITLE="[WIP] build: changelog automatic update"
            else
                TITLE="build: changelog automatic update"
            fi
            git commit -m "build: changelog automatic update"
            git push -u origin -f changelog_update
            "${DIR}/../../bin/create_pr.py" --title "${TITLE}" --body "" --base=master metwork-framework "${REPO}" changelog_update
        fi
    else
        echo "=> NO CHANGE"
    fi
    echo ""
    echo ""
done
