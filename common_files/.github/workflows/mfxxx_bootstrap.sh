#!/bin/bash

set -eu

{% if "mfext-addon" in "TOPICS"|getenv|from_json %}
    {% set MFEXT_ADDON = "1" %}
    {% set FORCED_REPO = "mfext" %}
{% else %}
    {% set MFEXT_ADDON = "0" %}
    {% set FORCED_REPO = REPO %}
{% endif %}
{% if REPO == "mfext" %}
    {% set DEP_MODULE = "" %}
{% else %}
    {% if MFEXT_ADDON == "1" %}
        {% set DEP_MODULE = "" %}
    {% else %}
        {% set DEP_MODULE = "mfext" %}
    {% endif %}
{% endif %}
cd /src
mkdir -p "/opt/metwork-${MFMODULE_LOWERCASE}-${TARGET_DIR}"
{% if REPO == "mfext" or MFEXT_ADDON == "1" %}
./bootstrap.sh "/opt/metwork-${MFMODULE_LOWERCASE}-${TARGET_DIR}"
{% else %}
./bootstrap.sh /opt/metwork-{% raw %}{{FORCED_REPO}}{% endraw %}-${TARGET_DIR} /opt/metwork-{% raw %}{{DEP_MODULE}}{% endraw %}-${DEP_DIR}
{% endif %}
cat adm/root.mk
env | sort
