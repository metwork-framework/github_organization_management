#!/bin/bash

git config --global credential.helper cache
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TMPDIR=/tmp/copy_branch.$$

function cleanup {
    rm -Rf "${TMPDIR}"
}

function changelog {
    # $1: TITLE
    # $2: STARTING_REV
    # $3: TAG_FILTER
    # $4: FILE
    # $5: REPO
    # $6: BRANCH
    cd "${TMPDIR}"
    if ! test -d "${5}"; then
        git clone "https://${USERNAME}:${PASSWORD}@github.com/metwork-framework/${5}.git"
    fi
    cd "${5}"
    git config user.email "metworkbot@metwork-framework.org"
    git config user.name "metworkbot"
    git checkout "${6}" || return 0
    set -x
    ghtc --title="${1}" --tags-regex="${3}" --include-type=FEAT --include-type=FIX --starting-rev="${2}" . >"${4}"
    set +x
    git add -u
    git add --all
    N=$(git diff --cached |wc -l)
    if test "${N}" -gt 0; then
        if test "${DEBUG:-}" = "1"; then
            git status
            git diff --cached
        else
            git commit -m "build: changelog automatic update"
            git push -u origin "${6}"
        fi
    else
        echo "=> NO CHANGE"
    fi
}

set -eu
trap cleanup EXIT

mkdir -p "${TMPDIR}"
if test "${LIMIT_TO_REPO}" != ""; then
    echo "${LIMIT_TO_REPO}" >"${TMPDIR}/repos"
else
    "${DIR}/list_repos.py" --topic=integration-level-3 >"${TMPDIR}/repos"
    "${DIR}/list_repos.py" --topic=integration-level-4 >>"${TMPDIR}/repos"
    "${DIR}/list_repos.py" --topic=integration-level-5 >>"${TMPDIR}/repos"
fi
for REPO in $(cat "${TMPDIR}/repos"); do
    echo "***** REPO: ${REPO} *****"
    echo ""
    INTEGRATION_LEVEL=$("${DIR}/get_integration_level.py" "${REPO}")
    if test "${INTEGRATION_LEVEL}" = "3"; then
        changelog CHANGELOG "" "v*" CHANGELOG.md "${REPO}" master
    else
        BRANCH=integration
        LATEST=$("${DIR}/latest_release.py" "${DIR}/../releases.json")
        changelog CHANGELOG "origin/${LATEST}" "no_tag_here" CHANGELOG.md "${REPO}" integration
        for T in $("${DIR}/active_releases.py" "${DIR}/../releases.json"); do
            BRANCH=$(echo "${T}" |awk -F ';' '{print $1;}')
            PREVIOUS=$(echo "${T}" |awk -F ';' '{print $2;}')
            TAGS=$(echo "${T}" |awk -F ';' '{print $3;}')
            TITLE=$(echo "${T}" |awk -F ';' '{print $4;}')
            changelog "${BRANCH} CHANGELOG" "origin/${PREVIOUS}" "${TAGS}" CHANGELOG.md "${REPO}" "${BRANCH}" || true
            #changelog "${BRANCH} CHANGELOG" "origin/integration" "origin/${PREVIOUS}" "origin/${BRANCH}" "${TAGS}" "${BRANCH}" "CHANGELOG-${TITLE}.md" "${REPO}" integration || true
            for T2 in $("${DIR}/active_releases.py" "${DIR}/../releases.json"); do
                BRANCH2=$(echo "${T2}" |awk -F ';' '{print $1;}')
                PREVIOUS2=$(echo "${T2}" |awk -F ';' '{print $2;}')
                TAGS2=$(echo "${T2}" |awk -F ';' '{print $3;}')
                TITLE2=$(echo "${T2}" |awk -F ';' '{print $4;}')
                if [[ ! ${BRANCH} > ${BRANCH2} ]]; then
                    continue
                fi
                changelog "${BRANCH2} CHANGELOG" "origin/${PREVIOUS2}" "${TAGS2}" "CHANGELOG-${TITLE2}.md" "${REPO}" "${BRANCH}" || true
            done
        done
    fi
    echo ""
    echo ""
done
