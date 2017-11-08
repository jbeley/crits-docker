#!/bin/bash

CRITS_HOME=${CRITS_HOME:-/data/crits}
CRITS_SERVICES_USED=${CRITS_SERVICES:-/data/crits_services}
CRITS_SERVICES=${CRITS_SERVICES:-/data/crits_services.unused}
MONGO_HOST=${MONGO_HOST:-localhsot}
CRITS_FQDN=${CRITS_HOME:-localhost}
CRITS_ADMINEMAIL=${CRITS_ADMINEMAIL:-crits@example.com}
CRITS_ADMINFN=${CRITS_ADMINFN:-Thomas}
CRITS_ADMINLN=${CRITS_ADMINLN:-Anderson}
CRITS_ADMINPW=${CRITS_ADMINPW:-$(openssl rand -base64 32)}
CRITS_ADMIN=${CRITS_ADMIN:-critsadmin}
CRITS_ORG=${CRITS_ORG:-DFIR}
SPLUNK_URL=${SPLUNK_URL:-https://splunk:8000/}


set -e -u
sleep 3
if [ -f /firstboot.tmp ] ;
then
        mkdir -p $CRITS_HOME && \
		mkdir -p $CRITS_SERVICES && \
		mkdir -p $CRITS_SERVICES_USED && \
		touch $CRITS_HOME/logs/crits.log && \
        chmod 664 $CRITS_HOME/logs/crits.log && \
        cp $CRITS_HOME/crits/config/database_example.py $CRITS_HOME/crits/config/database.py && \
        rm -rf /etc/apache2/sites-available && \
        cp $CRITS_HOME/extras/*.conf /etc/apache2 && \
        cp -r $CRITS_HOME/extras/sites-available /etc/apache2 && \
        rm /etc/apache2/sites-enabled/* && \
        ln -s /etc/apache2/sites-available/default-ssl /etc/apache2/sites-enabled/default-ssl  && \
		mkdir -p /etc/apache2/conf.d/ && \
        a2enmod ssl && \
        SK=$(python $CRITS_HOME/contrib/gen_secret_key.py) && \
        sed -i -e "s/^MONGO_HOST = 'localhost'/MONGO_HOST = \'$MONGO_HOST\'/g" $CRITS_HOME/crits/config/database.py && \
        sed -i -e "s/^\(SECRET_KEY = \).*$/\1\'${SK}\'/1" $CRITS_HOME/crits/config/database.py

        python $CRITS_HOME/manage.py create_default_collections && \
        python $CRITS_HOME/manage.py setconfig allowed_hosts "$CRITS_FQDN" && \
        python $CRITS_HOME/manage.py users -a \
            -e $CRITS_ADMINEMAIL -f $CRITS_ADMINFN \
            -l $CRITS_ADMINLN -p $CRITS_ADMINPW -s -u $CRITS_ADMIN -o $CRITS_ORG && \
        python $CRITS_HOME/manage.py setconfig debug False \
        python $CRITS_HOME/manage.py setconfig enable_api True \
        python $CRITS_HOME/manage.py setconfig crits_email $CRITS_ADMINEMAIL \
        python $CRITS_HOME/manage.py setconfig instance_url $CRITS_FQDN \
        python $CRITS_HOME/manage.py setconfig service_dirs $CRITS_SERVICES_USED \
        python $CRITS_HOME/manage.py setconfig splunk_search_url \
        "$SPLUNK_URL/en-US/app/search/search?earliest=-24h%40h&latest=now&display.page.search.mode=verbose&dispatch.sample_ratio=1&q=search%20*%20%20index%3Dbro%20" \
		python $CRITS_HOME/manage.py users -A  -u $CRITS_ADMIN
        chown -R www-data $CRITS_HOME $CRITS_SERVICES
        rm /firstboot.tmp
        logger $CRITS_ADMIN $CRITS_ADMINPW


fi


