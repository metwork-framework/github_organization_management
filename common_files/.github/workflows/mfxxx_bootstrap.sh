#!/bin/bash

set -eu

#We keep the names DRONE_* with github_actions because they are used by guess_version.sh
export DRONE_BRANCH=${BRANCH}
export DRONE_TAG=${TAG}
export DRONE=true

{% if "mfext-addon" in "TOPICS"|getenv|from_json %}
    {% set MFEXT_ADDON = "1" %}
{% else %}
    {% set MFEXT_ADDON = "0" %}
{% endif %}
cd /src
{% if REPO == "mfext" or MFEXT_ADDON == "1" %}
mkdir -p /opt/metwork-mfext-${TARGET_DIR}
./bootstrap.sh /opt/metwork-mfext-${TARGET_DIR}
{% else %}
mkdir -p /opt/metwork-{{REPO|lower}}-${TARGET_DIR}
./bootstrap.sh /opt/metwork-{{REPO|lower}}-${TARGET_DIR} /opt/metwork-mfext-${DEP_DIR}
{% endif %}
cat adm/root.mk
env | sort
