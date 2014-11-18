#!/bin/bash

# Go home and remember where it is
PWD=$(pwd)

# Install required packages
apt-get -y update && apt-get -y install python-dev python-flup python-pip expect git memcached sqlite3 libcairo2 libcairo2-dev python-cairo pkg-config


# Install Python packages
pip install \
	django==1.3 \
	python-memcached==1.53 \
	django-tagging==0.3.1 \
	whisper==0.9.12 \
	twisted==11.1.0 \
	txAMQP==0.6.2


# Make necessary directories
mkdir -p \
	/var/log/carbon \
	/var/log/graphite \
	/var/log/supervisor


# Install Graphite
git clone -b 0.9.12 https://github.com/graphite-project/graphite-web.git /usr/local/src/graphite-web
cd /usr/local/src/graphite-web
python ./setup.py install
cp ${PWD}/conf/graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py


# Install Whisper
git clone -b 0.9.12 https://github.com/graphite-project/whisper.git /usr/local/src/whisper
cd /usr/local/src/whisper
python ./setup.py install


# Install Carbon
git clone -b 0.9.12 https://github.com/graphite-project/carbon.git /usr/local/src/carbon
cd /usr/local/src/carbon
python ./setup.py install


# Init Django
cd ${PWD}
${PWD}/conf/misc/django_admin_init.exp


# Config files
cp ${PWD}/conf/graphite/* /opt/graphite/conf/


# Quick UI patch for /dashboard
/usr/bin/patch /opt/graphite/webapp/content/js/dashboard.js < ${PWD}/conf/misc/dashboard-patch.txt


# Daemon startup scripts
cp ${PWD}/conf/init.d/carbon /etc/init.d/carbon
cp ${PWD}/conf/init.d/graphite /etc/init.d/graphite
chmod +x /etc/init.d/carbon /etc/init.d/graphite

# Start daemons
/etc/init.d/carbon start
/etc/init.d/graphite start
