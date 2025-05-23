#!/bin/bash


OK_DEPS=$(cat list.txt|grep -v "#"|xargs)
OK_NOT_FOUND=$(cat list_ok_not_found.txt|grep -v "#"|xargs)

#N=$(cat /etc/redhat-release 2>/dev/null |grep -c "^CentOS release 6")
#if test "${N}" -eq 0; then
#    echo "We test this only on centos6"
#    exit 0
#fi

export PATH=${PATH}:${PWD}/..
RET=0

{% if "mfext-addon" not in "TOPICS"|getenv|from_json %}
cd "${MFMODULE_HOME}" || exit 1
cd opt || exit 1
for layer in *; do
    [[ -e $layer ]] || break
    cd "${layer}" || exit 1
    echo
    echo "=== System extra dependencies layer ${layer} ==="
    echo
    current_layer=$(cat .layerapi2_label)
    DEPS1=$(layer_wrapper --layers="${current_layer}" -- external_dependencies.sh |awk -F '/' '{print $NF}' |xargs)
    # We don t consider libraries available in the layer (they should not be here, probably a LD_LIBRARY_PATH issue)
    DEPS2=""
    for lib in ${DEPS1}; do
        found=$(find . -name "${lib}" -print)
        if test "${found}" == ""; then
            DEPS2="${DEPS2} ${lib}"
        fi
    done
    echo "--- external dependencies ---" "${DEPS2}"
    for DEP in ${DEPS2}; do
        FOUND=0
        for OK_DEP in ${OK_DEPS}; do
            if test "${DEP}" = "${OK_DEP}"; then
                FOUND=1
                break
            fi
        done
        if test "${FOUND}" = "1"; then
            continue
        fi
        echo "***** ${DEP} *****"
        echo "=== revert ldd ==="
        revert_ldd.sh "${DEP}"
        echo
        echo
        RET=1
    done
    DEPS3=$(layer_wrapper --layers="${current_layer}" -- external_dependencies_not_found.sh |xargs)
    # We don t consider libraries available in the layer (they should not be here, probably a LD_LIBRARY_PATH issue)
    DEPS4=""
    for lib in ${DEPS3}; do
        found=$(find . -name "${lib}" -print)
        if test "${found}" == ""; then
            DEPS4="${DEPS4} ${lib}"
        fi
    done
    echo "--- dependencies not found ---" ${DEPS4}
    for DEP in ${DEPS4}; do
        FOUND=0
        for OK_DEP in ${OK_NOT_FOUND}; do
            if test "${DEP}" = "${OK_DEP}"; then
                FOUND=1
                break
            fi
        done
        if test "${FOUND}" = "1"; then
            continue
        fi
        echo "***** ${DEP} *****"
        echo "=== revert ldd not found ==="
        revert_ldd_not_found.sh "${DEP}"
        echo
        echo
        RET=1
    done
    cd ..
done
{% else %}
cd "${MFEXT_HOME}" || exit 1
cd opt || exit 1
for layer in *; do
    [[ -e $layer ]] || break
    cd "${layer}" || exit 1
    if test -f .mfextaddon; then
        addon="mfextaddon_"$(cat .mfextaddon)
        if test "{{REPO}}" = "${addon}"; then
            echo
            echo "=== System extra dependencies layer ${layer} ==="
            echo
            current_layer=$(cat .layerapi2_label)
            DEPS1=$(layer_wrapper --layers="${current_layer}" -- external_dependencies.sh |awk -F '/' '{print $NF}' |xargs)
            # We don t consider libraries available in the layer (they should not be here, probably a LD_LIBRARY_PATH issue)
            DEPS2=""
            for lib in ${DEPS1}; do
                found=$(find . -name "${lib}" -print)
                if test "${found}" == ""; then
                    DEPS2="${DEPS2} ${lib}"
                fi
            done
            echo "--- external dependencies ---" "${DEPS2}"
            for DEP in ${DEPS2}; do
                FOUND=0
                for OK_DEP in ${OK_DEPS}; do
                    if test "${DEP}" = "${OK_DEP}"; then
                        FOUND=1
                        break
                    fi
                done
                if test "${FOUND}" = "1"; then
                    continue
                fi
                echo "***** ${DEP} *****"
                echo "=== revert ldd layer ${layer} ==="
                revert_ldd.sh "${DEP}"
                echo
                echo
                RET=1
            done
            DEPS3=$(layer_wrapper --layers="${current_layer}" -- external_dependencies_not_found.sh |xargs)
            # We don t consider libraries available in the layer (they should not be here, probably a LD_LIBRARY_PATH issue)
            DEPS4=""
            for lib in ${DEPS3}; do
                found=$(find . -name "${lib}" -print)
                if test "${found}" == ""; then
                    DEPS4="${DEPS4} ${lib}"
                fi
            done
            echo "--- dependencies not found ---" ${DEPS4}
            for DEP in ${DEPS4}; do
                FOUND=0
                for OK_DEP in ${OK_NOT_FOUND}; do
                    if test "${DEP}" = "${OK_DEP}"; then
                        FOUND=1
                        break
                    fi
                done
                if test "${FOUND}" = "1"; then
                    continue
                fi
                echo "***** ${DEP} *****"
                echo "=== revert ldd not found ==="
                revert_ldd_not_found.sh "${DEP}"
                echo
                echo
                RET=1
            done
        fi
    fi
    cd ..
done
{% endif %}

if test "${RET}" = "1"; then
    echo "Failure of dependencies test"
    exit 1
fi
