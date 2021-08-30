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
        if [ -f .build_os ]; then
            OS_VERSION=`cat .build_os`
        else
            OS_VERSION=${PAYLOAD_OS}
        fi;;
    push)
        if [ -f .build_os ]; then
            OS_VERSION=`cat .build_os`
        else
            OS_VERSION=centos6
        fi
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
echo "::set-output name=os::${OS_VERSION}"
echo "::set-output name=tag_branch::${TAG_BRANCH}"
echo "::set-output name=tag_latest::${TAG_LATEST}"
