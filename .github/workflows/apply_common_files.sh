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
    rm -Rf /tmp/common
    renvtpl "${DIR}/../../common_files" /tmp/common
    cd /tmp/common
    post_gen_project
    shopt -s dotglob
    rsync -av /tmp/common/ "/tmp/${REPO}/"
    cd "/tmp/${REPO}"
    git status
    git diff
    echo ""
    echo ""
done
