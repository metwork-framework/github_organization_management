#!/bin/bash

{% set LIST = REPO.split("-") %}
{% set MODULE = LIST[1] %}
{% set OS = LIST[2] %}

set -eu

if test "{{OS}}" = ""; then
    echo "ERROR: OS env is empty"
    exit 1
fi

case "${GITHUB_EVENT_NAME}" in
    repository_dispatch)
        BRANCH=${PAYLOAD_BRANCH};;
    push)
        case "${GITHUB_REF}" in
            refs/heads/*)
                BRANCH=${GITHUB_REF#refs/heads/};;
            *)
                BRANCH=null;
        esac;;
esac
if [ -z ${BRANCH} ]; then
  BRANCH=null
fi
TAG_BRANCH="metwork/{{MODULE}}-{{OS}}-buildimage:${BRANCH}"
TAG_LATEST=""
if test "${BRANCH}" = "master"; then
    TAG_LATEST="metwork/{{MODULE}}-{{OS}}-buildimage:latest"
fi 
echo "::set-output name=branch::${BRANCH}"
echo "::set-output name=tag_branch::${TAG_BRANCH}"
echo "::set-output name=tag_latest::${TAG_LATEST}"
