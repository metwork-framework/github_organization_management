#!/bin/bash

git config --global credential.helper cache
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMPDIR=/tmp/copy_branch.$$

function cleanup {
    rm -Rf "${TMPDIR}"
}

function changelog {
    # $1: TITLE
    # $2: REV
    # $3: EXCLUDE
    # $4: INCLUDE
    # $5: TAG_FILTER
    # $6: BASE
    # $7: FILE
    # $8: REPO
    # $9: BRANCH
    cd "${TMPDIR}"
    if ! test -d "${8}"; then
        git clone "https://${USERNAME}:${PASSWORD}@github.com/metwork-framework/${8}.git"
    fi
    cd "${8}"
    git config user.email "metworkbot@metwork-framework.org"
    git config user.name "metworkbot"
    #if test "${9}" != "master"; then
        git checkout "${9}"
    #fi
    git checkout -b changelog_update
    set -x
    auto-changelog --template-dir="${DIR}/../../changelog_templates" --title="${1}" --rev="${2}" --exclude-branches="${3}" --include-branches="${4}" --tag-filter="${5}" --output="./${7}"
    set +x
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
            "${DIR}/../../bin/create_pr.py" --title "${TITLE}" --body "" --base="${6}" metwork-framework "${REPO}" changelog_update
        fi
    else
        echo "=> NO CHANGE"
    fi
    git checkout "${9}"
    git branch -D changelog_update
    #rm -Rf "${TMPDIR:?}/${8}"
}

set -eu
trap cleanup EXIT

mkdir -p "${TMPDIR}"
if test "${LIMIT_TO_REPO}" != ""; then
    echo "${LIMIT_TO_REPO}" >"${TMPDIR}/repos"
else
    "${DIR}/../../bin/get_repos.py" --topic=integration-level-3 metwork-framework >"${TMPDIR}/repos"
    "${DIR}/../../bin/get_repos.py" --topic=integration-level-4 metwork-framework >>"${TMPDIR}/repos"
    "${DIR}/../../bin/get_repos.py" --topic=integration-level-5 metwork-framework >>"${TMPDIR}/repos"
fi
for REPO in $(cat "${TMPDIR}/repos"); do
    echo "***** REPO: ${REPO} *****"
    echo ""
    INTEGRATION_LEVEL=$("${DIR}/../../bin/get_integration_level.py" metwork-framework "${REPO}")
    if test "${INTEGRATION_LEVEL}" = "3"; then
        changelog CHANGELOG master nothing master "v*" master CHANGELOG.md "${REPO}" master
    else
        BRANCH=integration
        LATEST=$("${DIR}/../../bin/latest_release.py" "${DIR}/../../releases.json")
        changelog CHANGELOG origin/integration "origin/${LATEST}" origin/integration xxxxxxxxxxx integration CHANGELOG.md "${REPO}" "${BRANCH}"
        for T in $("${DIR}/../../bin/active_releases.py" "${DIR}/../../releases.json"); do
            BRANCH=$(echo "${T}" |awk -F ';' '{print $1;}')
            PREVIOUS=$(echo "${T}" |awk -F ';' '{print $2;}')
            TAGS=$(echo "${T}" |awk -F ';' '{print $3;}')
            changelog "${BRANCH} CHANGELOG" "origin/${BRANCH}" "origin/${PREVIOUS}" "origin/${BRANCH}" "${TAGS}" "${BRANCH}" CHANGELOG.md "${REPO}" "${BRANCH}"
            for T2 in $("${DIR}/../../bin/active_releases.py" "${DIR}/../../releases.json"); do
                BRANCH2=$(echo "${T2}" |awk -F ';' '{print $1;}')
                PREVIOUS2=$(echo "${T2}" |awk -F ';' '{print $2;}')
                TAGS2=$(echo "${T2}" |awk -F ';' '{print $3;}')
                TITLE2=$(echo "${T2}" |awk -F ';' '{print $4;}')
                if [[ ! ${BRANCH} > ${BRANCH2} ]]; then
                    continue
                fi
                changelog "${BRANCH2} CHANGELOG" "origin/${BRANCH2}" "origin/${PREVIOUS2}" "origin/${BRANCH2}" "${TAGS2}" "${BRANCH}" "CHANGELOG-${TITLE2}.md" "${REPO}" "${BRANCH}"
            done
        done
    fi
    echo ""
    echo ""
done
