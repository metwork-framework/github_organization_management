#!/bin/bash

git config --global credential.helper cache
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -eu

"${DIR}/../../bin/get_repos.py" --topic=integration-level-5 metwork-framework >/tmp/repos
for REPO in $(cat /tmp/repos); do
    echo "***** REPO: ${REPO} *****"
    echo ""
    cd /tmp
    git clone "https://${USERNAME}:${PASSWORD}@github.com/metwork-framework/${REPO}.git"
    cd "${REPO}"
    git checkout -b common_files_force
    rm -Rf /tmp/common
    renvtpl "${DIR}/../../common_files" /tmp/common
    cd /tmp/common
    post_gen_project
    shopt -s dotglob
    rsync -av /tmp/common/ "/tmp/${REPO}/"
    cd "/tmp/${REPO}"
    find . -type f -name "*.forcedelete" |sed 's/\.forcedelete$//g' |xargs rm -rf
    find . -type f -name "*.forcedelete" -exec rm -f {} \;
    git add -u
    git add --all
    N=$(git diff --cached |wc -l)
    if test "${N}" -gt 0; then
        git status
        git diff --cached
        git commit -m "build: sync common files from github_organization_management repository"
        git push -u origin -f common_files_force
        "${DIR}/../../bin/create_pr.py" --title "WIP: just a test" --body "" --base=integration metwork-framework "${REPO}" common_files_force
    fi
    echo ""
    echo ""
    exit 0
done
