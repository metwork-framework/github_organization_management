#!/bin/bash

NB_DAYS_BEFORE_EXP=`certbot certificates | grep VALID | cut -d"(" -f 2 | cut -d " " -f2`
if [ "$NB_DAYS_BEFORE_EXP" -lt "30" ]; then
    #Certificate is expiring within 30 days, we can renew it
    /usr/sbin/service metwork stop mfserv
    echo "metwork-framework.org www.metwork-framework.org" | certbot certonly --standalone
    yes | cp -f /etc/letsencrypt/live/metwork-framework.org/fullchain.pem /home/mfserv/config/fullchain.pem
    yes | cp -f /etc/letsencrypt/live/metwork-framework.org/privkey.pem /home/mfserv/config/privkey.pem
    chmod 0644 /home/mfserv/config/fullchain.pem /home/mfserv/config/privkey.pem
    chown mfserv:metwork /home/mfserv/config/fullchain.pem /home/mfserv/config/privkey.pem
    /usr/sbin/service metwork start mfserv 
    certbot certificates > /root/certificates.log
fi
/usr/bin/rm -f /var/log/letsencrypt/letsencrypt.log.[3456789][0123456789]

