#!/bin/bash

#set -eu
set -x

if test -d /buildcache; then export BUILDCACHE=/buildcache; fi

#We keep the names DRONE_* with github_actions because they are used by guess_version.sh
export DRONE_BRANCH=${BRANCH}
export DRONE_TAG=${TAG}
export DRONE=true
{% if REPO != "mfextaddon_python3_ia" %}
    if test "${OS_VERSION}" = "centos6"; then export METWORK_BUILD_OS=generic; else export METWORK_BUILD_OS=${OS_VERSION}; fi
{% else %}
    if test "${OS_VERSION}" = "centos7"; then export METWORK_BUILD_OS=generic; else export METWORK_BUILD_OS=${OS_VERSION}; fi
{% endif %}

{% if REPO == "mfextaddon_mapserver" or REPO == "mfextaddon_scientific" %}
    yum install -y metwork-mfext-layer-python2-${BRANCH##release_}
{% elif REPO == "mfextaddon_vim" %}
    yum install -y metwork-mfext-layer-python2_devtools-${BRANCH##release_}
{% endif %}
{% if REPO == "mfbus" %}
    yum -y install metwork-mfext-layer-rabbitmq-${DRONE_BRANCH##release_}
{% endif %}

cd /src

{% if "mfext-addon" in "TOPICS"|getenv|from_json %}
{% set MODULE = "mfext" %}
{% else %}
{% set MODULE = REPO|lower %}
{% endif %}

mkdir -p "/opt/metwork-{{MODULE}}-${TARGET_DIR}"

if test -d /pub; then mkdir -p /pub/metwork/continuous_integration/buildlogs/${BRANCH}/{{MODULE}}/${OS_VERSION}/${GITHUB_RUN_NUMBER}; fi
export BUILDLOGS=/pub/metwork/continuous_integration/buildlogs/${BRANCH}/{{MODULE}}/${OS_VERSION}/${GITHUB_RUN_NUMBER}

make >${BUILDLOGS}/make.log 2>&1 || ( tail -200 ${BUILDLOGS}/make.log ; exit 1 )

OUTPUT=$(git status --short | grep -v buildlogs | grep -v buildcache)

if test "${OUTPUT}" != ""; then
    echo "ERROR non empty git status output ${OUTPUT}"
    echo "git diff output"
    git diff
    exit 1
fi

MODULEHASH=`/opt/metwork-mfext-${TARGET_DIR}/bin/mfext_wrapper module_hash 2>module_hash.debug`
if test -f /opt/metwork-mfext-${TARGET_DIR}/.dhash; then cat /opt/metwork-mfext-${TARGET_DIR}/.dhash; fi
cat module_hash.debug |sort |uniq ; rm -f module_hash.debug
echo "${MODULEHASH}${DRONE_TAG}${DRONE_BRANCH}" |md5sum |cut -d ' ' -f1 >.build_hash
if test -f "${BUILDCACHE}/build_hash_{{MODULE}}_${BRANCH}_`cat .build_hash`"; then
    echo "::set-output name=bypass::true"
    echo "::set-output name=buildcache::null"
    exit 0
fi

if test -d docs; then make docs >${BUILDLOGS}/make_doc.log 2>&1 || ( tail -200 ${BUILDLOGS}/make_doc.log ; exit 1 ); fi
if test -d doc; then make doc >${BUILDLOGS}/make_doc.log 2>&1 || ( tail -200 ${BUILDLOGS}/make_doc.log ; exit 1 ); fi
rm -Rf html_doc
if test -d /opt/metwork-{{MODULE}}-${TARGET_DIR}/html_doc; then cp -Rf /opt/metwork-{{MODULE}}-${TARGET_DIR}/html_doc . ; fi
make test >${BUILDLOGS}/make_test.log 2>&1 || ( tail -200 ${BUILDLOGS}/make_test.log ; exit 1 )
make RELEASE_BUILD=${GITHUB_RUN_NUMBER} rpm >${BUILDLOGS}/make_rpm.log 2>&1 || ( tail -200 ${BUILDLOGS}/make_rpm.log ; exit 1 )

mkdir rpms
mv /opt/metwork-{{MODULE}}-${TARGET_DIR}/*.rpm rpms

rm -f ${BUILDCACHE}/build_hash_{{MODULE}}_${BRANCH}_*
hash_file=${BUILDCACHE}/build_hash_{{MODULE}}_${BRANCH}_`cat .build_hash`
touch ${hash_file}

echo "::set-output name=bypass::false"
echo "::set-output name=buildcache::${hash_file}"
