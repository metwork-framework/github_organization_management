#!/bin/bash

{% set LIST = REPO.split("-") %}
{% set MODULE = LIST[1] %}
{% set OS = LIST[2] %}

#set -eu
set -x

if test "{{OS}}" = ""; then
    echo "ERROR: OS env is empty"
    exit 1
fi

case "${GITHUB_EVENT_NAME}" in
    repository_dispatch)
        BRANCH=${PAYLOAD_BRANCH}
        case "${BRANCH}" in
            experimental_centos8)
                OS=${PAYLOAD_OS};;
            *)
                OS=centos6;;
        esac;;
    push)
        OS=centos6
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
TAG_LATEST=""
{% if REPO|fnmatch('docker-mf*-*-buildimage') %}
TAG_BRANCH="metwork/{{MODULE}}-{{OS}}-buildimage:${BRANCH}"
if test "${BRANCH}" = "master"; then
    TAG_LATEST="metwork/{{MODULE}}-{{OS}}-buildimage:latest"
fi 
{% endif %}
{% if REPO|fnmatch('docker-mf*-*-testimage') %}
TAG_BRANCH="metwork/{{MODULE}}-{{OS}}-testimage:${BRANCH}"
if test "${BRANCH}" = "master"; then
    TAG_LATEST="metwork/{{MODULE}}-{{OS}}-testimage:latest"
fi 
{% endif %}
echo "::set-output name=branch::${BRANCH}"
echo "::set-output name=os::${OS}"
echo "::set-output name=tag_branch::${TAG_BRANCH}"
echo "::set-output name=tag_latest::${TAG_LATEST}"
