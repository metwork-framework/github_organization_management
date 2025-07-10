#!/bin/bash

find /pub/metwork/continuous_integration/buildlogs/ -type f -mtime +4 -exec rm -f {} \; 2>/dev/null
find /pub/metwork/continuous_integration/buildlogs/ -type d -exec rmdir {} \; 2>/dev/null

find /pub/metwork/continuous_integration/docs/ -type f -not -path '*/integration/*' -a -not -path '*/master/*' -a -not -path '*/release_*/*' -mtime +5 -exec rm -f {} \; 2>/dev/null
find /pub/metwork/continuous_integration/docs/ -type d -not -path '*/integration/*' -a -not -path '*/master/*' -a -not -path '*/release_*/*' -exec rmdir {} \; 2>/dev/null

BRANCHES=$(find /pub/metwork/continuous_integration/rpms/ -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)
for BRANCH in ${BRANCHES}; do
  BRANCH_SHORT=$(echo "${BRANCH}" |sed 's/release_//g')
  if test -L "/pub/metwork/continuous_integration/rpms/${BRANCH}"; then
    continue
  fi
  for OS in centos6 centos7 centos8; do
    DELETED=0
    for MODULE in mfext mfext-full mfext-${BRANCH_SHORT} mfcom mfadmin mfadmin-full mfadmin-${BRANCH_SHORT} mfadmin-layer-logs-${BRANCH_SHORT} mfadmin-layer-logs_loki-${BRANCH_SHORT} mfadmin-layer-metrics-${BRANCH_SHORT} mfadmin-layer-java-${BRANCH_SHORT} mfbase mfbase-full mfbase-${BRANCH_SHORT} mfdata mfdata-full mfdata-${BRANCH_SHORT} mfserv mfserv-full mfserv-${BRANCH_SHORT} mfserv-layer-nodejs-${BRANCH_SHORT} mfsysmon mfsysmon-full mfsysmon-${BRANCH_SHORT} mfbus mfbus-full mfbus-${BRANCH_SHORT} mfext-layer-devtools-${BRANCH_SHORT} mfext-layer-java-${BRANCH_SHORT} mfext-layer-monitoring-${BRANCH_SHORT} mfext-layer-nodejs-${BRANCH_SHORT} mfext-layer-openresty-${BRANCH_SHORT} mfext-layer-python3_devtools-${BRANCH_SHORT} mfext-layer-python3_scientific_core-${BRANCH_SHORT} mfext-layer-scientific_core-${BRANCH_SHORT} mfext-layer-tcltk-${BRANCH_SHORT} mfext-layer-mapserver-${BRANCH_SHORT} mfext-layer-python3_mapserverapi-${BRANCH_SHORT} mfext-layer-python2_mapserverapi-${BRANCH_SHORT} mfext-layer-scientific-${BRANCH_SHORT} mfext-layer-python3_scientific-${BRANCH_SHORT} mfext-layer-python3_extratools-${BRANCH_SHORT} mfext-layer-python2_scientific-${BRANCH_SHORT} mfext-layer-python3_vim-${BRANCH_SHORT} mfext-layer-python2_vim-${BRANCH_SHORT} mfext-layer-vim-${BRANCH_SHORT} mfext-layer-python3_ia-${BRANCH_SHORT} mfext-layer-python2-${BRANCH_SHORT} mfext-layer-python2_core-${BRANCH_SHORT} mfext-layer-python2_devtools-${BRANCH_SHORT} mfext-layer-scientific_system_libraries-${BRANCH_SHORT} mfext-layer-php-${BRANCH_SHORT} mfext-layer-rabbitmq_system_libraries-${BRANCH_SHORT} mfext-layer-rabbitmq-${BRANCH_SHORT} mfext-layer-scientific_system_libraries-${BRANCH_SHORT} mfext-layer-radartools-${BRANCH_SHORT} mfext-layer-python3_radartools-${BRANCH_SHORT} mfext-layer-elasticsearch-${BRANCH_SHORT} mfext-layer-soprano-${BRANCH_SHORT}; do
      echo "- Searching for ${BRANCH}/${OS}/${MODULE}/..."
      # We only keep rpms of the last ci
      for N in `find /pub/metwork/continuous_integration/rpms/${BRANCH}/${OS} -type f -name "metwork-${MODULE}-${BRANCH_SHORT}.ci*.rpm" 2>/dev/null |xargs -r -n 1 basename |grep '\.ci[0-9][0-9]*\.' |sed 's/^.*\.\(ci[0-9][0-9]*\)\..*$/\1/g' |sed 's/ci//g' |sort -rn |uniq |awk 'NR>1'`; do
        echo "    => deleting /pub/metwork/continuous_integration/rpms/${BRANCH}/${OS}/metwork-${MODULE}-${BRANCH_SHORT}.ci${N}.*.rpm"
        rm -f /pub/metwork/continuous_integration/rpms/${BRANCH}/${OS}/metwork-${MODULE}-${BRANCH_SHORT}.ci${N}.*.rpm
        DELETED=1
      done
      # For each kept ci, we only keep rpms of the last build
      for N in `find /pub/metwork/continuous_integration/rpms/${BRANCH}/${OS} -type f -name "metwork-${MODULE}-${BRANCH_SHORT}.ci*.rpm" 2>/dev/null |xargs -r -n 1 basename |grep '\.ci[0-9][0-9]*\.' |sed 's/^.*\.\(ci[0-9][0-9]*\)\..*$/\1/g' |sed 's/ci//g' |sort -rn |uniq`; do
        for M in `find /pub/metwork/continuous_integration/rpms/${BRANCH}/${OS} -type f -name "metwork-${MODULE}-${BRANCH_SHORT}.ci${N}*.rpm" 2>/dev/null |xargs -r -n 1 basename | awk -F "-" '{ print $NF }' | awk -F "." '{ print $1 }' | sort -rn | uniq |awk 'NR>1'`; do
          echo "    => deleting /pub/metwork/continuous_integration/rpms/${BRANCH}/${OS}/metwork-${MODULE}-${BRANCH_SHORT}.ci${N}.*-${M}*.x86_64.rpm"
          rm -f /pub/metwork/continuous_integration/rpms/${BRANCH}/${OS}/metwork-${MODULE}-${BRANCH_SHORT}.ci${N}.*-${M}*.x86_64.rpm 
          DELETED=1
        done
      done
    done
    if test "${DELETED}" = "1"; then
      cd /pub/metwork/continuous_integration/rpms/${BRANCH}/${OS} && su -c "createrepo ." metworkpub
    fi
  done
done

for DIR in `find /pub/metwork/continuous_integration/rpms -mindepth 2 -maxdepth 2 -type d -not -path '*/integration/*' -a -not -path '*/master/*' -a -not -path '*/release_*/*'`; do
  echo "Searching in ${DIR}..."
  N=`find ${DIR} -type f -name "*.rpm" -mtime +15 2>/dev/null |wc -l`
  if test ${N} -gt 0; then
    find ${DIR} -type f -name "*.rpm" -mtime +15 -exec rm -f {} \; 2>/dev/null
    cd ${DIR} && su -c "createrepo ." metworkpub
  fi
  N=`find ${DIR} -type f -name "*.rpm" 2>/dev/null |wc -l`
  if test ${N} -eq 0; then
    rm -Rf ${DIR}
  fi
done

find /pub/metwork/continuous_integration/rpms -mindepth 1 -maxdepth 1 -type d -exec rmdir {} \; >/dev/null 2>&1

chown -RL metworkpub:metworkpub /pub/metwork
chmod -R 755 /pub/metwork

#Private addons
find /private/metwork_addons/continuous_integration/rpms -mindepth 1 -maxdepth 1 -type d -exec rmdir {} \; >/dev/null 2>&1

find /private/metwork_addons/continuous_integration/docs/ -type f -not -path '*/integration/*' -a -not -path '*/master/*' -a -not -path '*/release_*/*' -mtime +15 -exec rm -f {} \; 2>/dev/null
find /private/metwork_addons/continuous_integration/docs/ -type d -not -path '*/integration/*' -a -not -path '*/master/*' -a -not -path '*/release_*/*' -exec rmdir {} \; 2>/dev/null

BRANCHES=$(find /private/metwork_addons/continuous_integration/rpms/ -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)
for BRANCH in ${BRANCHES}; do
  BRANCH_SHORT=$(echo "${BRANCH}" |sed 's/release_//g')
  if test -L "/private/metwork_addons/continuous_integration/rpms/${BRANCH}"; then
    continue
  fi
  for OS in centos6 centos7 centos8; do
    DELETED=0
    for MODULE in  mfext-layer-python2_radartools-${BRANCH_SHORT} mfext-layer-python3_radartools-${BRANCH_SHORT} mfext-layer-radartools-${BRANCH_SHORT} mfext-layer-soprano-${BRANCH_SHORT} mfext-layer-elasticsearch-${BRANCH_SHORT}; do
      echo "- Searching for ${BRANCH}/${OS}/${MODULE}/..."
      # We only keep rpms of the last ci
      for N in `find /private/metwork_addons/continuous_integration/rpms/${BRANCH}/${OS} -type f -name "metwork-${MODULE}-${BRANCH_SHORT}.ci*.rpm" 2>/dev/null |xargs -r -n 1 basename |grep '\.ci[0-9][0-9]*\.' |sed 's/^.*\.\(ci[0-9][0-9]*\)\..*$/\1/g' |sed 's/ci//g' |sort -rn |uniq |awk 'NR>1'`; do
        echo "    => deleting /private/metwork_addons/continuous_integration/rpms/${BRANCH}/${OS}/metwork-${MODULE}-${BRANCH_SHORT}.ci${N}.*.rpm"
        rm -f /private/metwork_addons/continuous_integration/rpms/${BRANCH}/${OS}/metwork-${MODULE}-${BRANCH_SHORT}.ci${N}.*.rpm
        DELETED=1
      done
      # For each kept ci, we only keep rpms of the last build
      for N in `find /private/metwork_addons/continuous_integration/rpms/${BRANCH}/${OS} -type f -name "metwork-${MODULE}-${BRANCH_SHORT}.ci*.rpm" 2>/dev/null |xargs -r -n 1 basename |grep '\.ci[0-9][0-9]*\.' |sed 's/^.*\.\(ci[0-9][0-9]*\)\..*$/\1/g' |sed 's/ci//g' |sort -rn |uniq`; do
        for M in `find /private/metwork_addons/continuous_integration/rpms/${BRANCH}/${OS} -type f -name "metwork-${MODULE}-${BRANCH_SHORT}.ci${N}*.rpm" 2>/dev/null |xargs -r -n 1 basename | awk -F "-" '{ print $NF }' | awk -F "." '{ print $1 }' | sort -rn | uniq |awk 'NR>1'`; do
          echo "    => deleting /private/metwork_addons/continuous_integration/rpms/${BRANCH}/${OS}/metwork-${MODULE}-${BRANCH_SHORT}.ci${N}.*-${M}*.x86_64.rpm"
          rm -f /private/metwork_addons/continuous_integration/rpms/${BRANCH}/${OS}/metwork-${MODULE}-${BRANCH_SHORT}.ci${N}.*-${M}*.x86_64.rpm 
          DELETED=1
        done
      done
    done
    if test "${DELETED}" = "1"; then
      cd /private/metwork_addons/continuous_integration/rpms/${BRANCH}/${OS} && su -c "createrepo ." metworkpub
    fi
  done
done

for DIR in `find /private/metwork_addons/continuous_integration/rpms -mindepth 2 -maxdepth 2 -type d -not -path '*/integration/*' -a -not -path '*/master/*' -a -not -path '*/release_*/*'`; do
  echo "Searching in ${DIR}..."
  N=`find ${DIR} -type f -name "*.rpm" -mtime +15 2>/dev/null |wc -l`
  if test ${N} -gt 0; then
    find ${DIR} -type f -name "*.rpm" -mtime +15 -exec rm -f {} \; 2>/dev/null
    cd ${DIR} && su -c "createrepo ." metworkpub
  fi
  N=`find ${DIR} -type f -name "*.rpm" 2>/dev/null |wc -l`
  if test ${N} -eq 0; then
    rm -Rf ${DIR}
  fi
done
find /private/metwork_addons/continuous_integration/rpms -mindepth 1 -maxdepth 1 -type d -exec rmdir {} \; >/dev/null 2>&1

chown -RL metworkpub:metworkpub /private/metwork_addons
chmod -R 755 /private/metwork_addons
