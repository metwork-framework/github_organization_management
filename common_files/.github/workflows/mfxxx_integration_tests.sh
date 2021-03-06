#!/bin/bash

set -eu
set -x

cd /src

{% if REPO == "mfext" %}
    yum -y localinstall ./rpms/metwork-mfext*.rpm
    if test -d "integration_tests"; then cd integration_tests; /opt/metwork-mfext/bin/mfext_wrapper ./run_integration_tests.sh; cd ..; fi
{% else %}
echo -e "[metwork_${DEP_BRANCH}]" >/etc/yum.repos.d/metwork.repo
echo -e "name=Metwork Continuous Integration Branch ${DEP_BRANCH}" >> /etc/yum.repos.d/metwork.repo
echo -e "baseurl=http://metwork-framework.org/pub/metwork/continuous_integration/rpms/${DEP_BRANCH}/${OS_VERSION}/" >> /etc/yum.repos.d/metwork.repo
echo -e "gpgcheck=0\n\enabled=1\n\metadata_expire=0\n" >>/etc/yum.repos.d/metwork.repo
{% if "mfext-addon" in "TOPICS"|getenv|from_json %}
    for rpm in ./rpms/metwork-mfext*.rpm; do rpm -qp --requires ./$rpm | grep metwork | grep -v "=" >> liste_dep; done
    cat liste_dep | sort -u > liste_dep2
    yum -y install `cat liste_dep2`
    rm -f liste_dep liste_dep2
{% if REPO == "mfextaddon_python2" %}
    yum -y install metwork-mfext-layer-tcltk
{% endif %}
{% if REPO == "mfextaddon_soprano" %}
    yum -y localinstall `ls -lrt /private/metwork_addons/continuous_integration/rpms/${BRANCH}/${OS_VERSION}/metwork-mfext-layer-python3_radartools* | tail -1 | awk '{print $NF}'`
{% endif %}
    rm /etc/yum.repos.d/metwork.repo
    yum clean all
    yum -y localinstall ./rpms/metwork-mfext*.rpm
    if test -d "integration_tests"; then cd integration_tests; /opt/metwork-mfext/bin/mfext_wrapper ./run_integration_tests.sh; cd ..; fi
{% else %}
{% if REPO == "mfdata_python2_tests" %}
    yum -y install metwork-mfdata-full metwork-mfext-layer-python2
    yum -y install git make
    git init python2_tests
    cd python2_tests
    git remote add -t ${DEP_BRANCH} -f origin https://github.com/metwork-framework/mfdata.git
    git config core.sparseCheckout true
    echo "integration_tests/" > .git/info/sparse-checkout
    git pull origin ${DEP_BRANCH}
    yum -y install vsftpd ftp
    service vsftpd start
    echo -e "mfdata\nmfdata" | passwd mfdata
    su --command="mfdata.init" - mfdata
    su --command="mfdata.start" - mfdata
    su --command="mfdata.status" - mfdata
    if test -d "integration_tests"; then chown -R mfdata integration_tests; cd integration_tests; su --command="cd `pwd`; ./run_integration_tests.sh" - mfdata; cd ..; fi
    su --command="mfdata.stop" - mfdata
{% elif REPO == "mfserv_python2_tests" %}
    yum -y install metwork-mfserv-full metwork-mfext-layer-python2
    yum -y install git make
    git init python2_tests
    cd python2_tests
    git remote add -t ${DEP_BRANCH} -f origin https://github.com/metwork-framework/mfserv.git
    git config core.sparseCheckout true
    echo "integration_tests/" > .git/info/sparse-checkout
    git pull origin ${DEP_BRANCH}
    su --command="mfserv.init" - mfserv
    su --command="mfserv.start" - mfserv
    su --command="mfserv.status" - mfserv
    if test -d "integration_tests"; then chown -R mfserv integration_tests; cd integration_tests; su --command="cd `pwd`; ./run_integration_tests.sh" - mfserv; cd ..; fi
    su --command="mfserv.stop" - mfserv
{% else %}
    yum -y localinstall ./rpms/metwork-{{REPO}}*.rpm
    yum -y install make
{% if REPO == "mfdata" %}
    yum -y install vsftpd ftp
    service vsftpd start
    echo -e "mfdata\nmfdata" | passwd mfdata
{% endif %}
    su --command="{{REPO}}.init" - {{REPO}}
    su --command="{{REPO}}.start" - {{REPO}}
    su --command="{{REPO}}.status" - {{REPO}}
    if test -d "integration_tests"; then chown -R {{REPO}} integration_tests; cd integration_tests; su --command="cd `pwd`; ./run_integration_tests.sh" - {{REPO}}; cd ..; fi
    su --command="{{REPO}}.stop" - {{REPO}}
{% endif %}
{% endif %}
{% endif %}
