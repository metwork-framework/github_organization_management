#!/bin/bash

#set -eu
set -x

if test -d /buildcache; then export BUILDCACHE=/buildcache; fi

#We keep the names DRONE_* with github_actions because they are used by guess_version.sh
export DRONE_BRANCH=${BRANCH}
export DRONE_TAG=${TAG}
export DRONE=true

{% if "github-selfhosted" in "TOPICS"|getenv|from_json %}
#Security in case where previous build has been canceled (unwanted outputs may have remained)
rm -rf html_doc rpms .build_hash
{% endif %}

    if test "${OS_VERSION}" = "centos8"; then export METWORK_BUILD_OS=generic; else export METWORK_BUILD_OS=${OS_VERSION}; fi

{% if REPO == "mfextaddon_python3_ia" %}
    yum install -y metwork-mfext-layer-python3_scientific-${BRANCH##release_}
{% elif REPO == "mfextaddon_radartools" %}
    yum install -y boost-devel
    yum install -y metwork-mfext-layer-python3_scientific-${BRANCH##release_}
{% elif REPO == "mfextaddon_soprano" %}
    yum -y localinstall `ls -lrt /private/metwork_addons/continuous_integration/rpms/${DRONE_BRANCH}/${OS_VERSION}/metwork-mfext-layer-radartools* | tail -1 | awk '{print $NF}'`
    yum -y localinstall `ls -lrt /private/metwork_addons/continuous_integration/rpms/${DRONE_BRANCH}/${OS_VERSION}/metwork-mfext-layer-python3_radartools* | tail -1 | awk '{print $NF}'`
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

mkdir -p buildlogs
export BUILDLOGS=buildlogs

make >${BUILDLOGS}/make.log 2>&1 || ( tail -200 ${BUILDLOGS}/make.log ; exit 1 )

OUTPUT=$(git status --short | grep -v buildlogs | grep -v buildcache)

if test "${OUTPUT}" != ""; then
    echo "ERROR non empty git status output ${OUTPUT}"
    echo "git diff output"
    git diff
    exit 1
fi

{% if "github-selfhosted" in "TOPICS"|getenv|from_json %}
MODULEHASH=`/opt/metwork-mfext-${TARGET_DIR}/bin/mfext_wrapper module_hash 2>module_hash.debug`
if test -f /opt/metwork-mfext-${TARGET_DIR}/.dhash; then cat /opt/metwork-mfext-${TARGET_DIR}/.dhash; fi
cat module_hash.debug |sort |uniq ; rm -f module_hash.debug
echo "${MODULEHASH}${DRONE_TAG}${DRONE_BRANCH}" |md5sum |cut -d ' ' -f1 >.build_hash
if test -f "${BUILDCACHE}/build_hash_{{REPO}}_${BRANCH}_`cat .build_hash`"; then
    echo "bypass=true" >> $GITHUB_OUTPUT
    echo "buildcache=null" >> $GITHUB_OUTPUT
    exit 0
fi
{% endif %} 

if test -d docs; then make docs >${BUILDLOGS}/make_doc.log 2>&1 || ( tail -200 ${BUILDLOGS}/make_doc.log ; exit 1 ); fi
if test -d doc; then make doc >${BUILDLOGS}/make_doc.log 2>&1 || ( tail -200 ${BUILDLOGS}/make_doc.log ; exit 1 ); fi
rm -Rf html_doc
if test -d /opt/metwork-{{MODULE}}-${TARGET_DIR}/html_doc; then cp -Rf /opt/metwork-{{MODULE}}-${TARGET_DIR}/html_doc . ; fi
make test >${BUILDLOGS}/make_test.log 2>&1 || ( tail -200 ${BUILDLOGS}/make_test.log ; exit 1 )
make RELEASE_BUILD=${GITHUB_RUN_NUMBER} rpm >${BUILDLOGS}/make_rpm.log 2>&1 || ( tail -200 ${BUILDLOGS}/make_rpm.log ; exit 1 )

mkdir rpms
mv /opt/metwork-{{MODULE}}-${TARGET_DIR}/*.rpm rpms

{% if "github-selfhosted" in "TOPICS"|getenv|from_json %}
rm -f ${BUILDCACHE}/build_hash_{{REPO}}_${BRANCH}_*
hash_file=${BUILDCACHE}/build_hash_{{REPO}}_${BRANCH}_`cat .build_hash`
touch ${hash_file}
rm -f ./build_hash
chown 1018:1018 ${hash_file}
chmod 664 ${hash_file}
echo "buildcache=${hash_file}" >> $GITHUB_OUTPUT
{% endif %} 

echo "bypass=false" >> $GITHUB_OUTPUT
