#!/bin/bash

function wait_for_service() {
	local start_ts=$(date +%s)
	local host=$1
	local port=$2
	local timeout=$3
	local sleeped=0
	while true; do
	    (echo > /dev/tcp/$host/$port) >/dev/null 2>&1
	    result=$?
	    if [[ $result -eq 0 ]]; then
	        end_ts=$(date +%s)
	        echo "$host:$port is available after $((end_ts - start_ts)) seconds"
	        break
	    fi
	    echo "Waiting"
	    sleep 5
	
	    sleeped=$((sleeped+5))
	    if [ $sleeped -ge $timeout ]; then
	    	echo "Timeout!"
	    	exit 1
		fi
	done
}

set -xe

CERT_DIR="/usr/share/igi-test-ca"
GLOBUS_DIR="${HOME}/.globus"
TS_DIR="/opt/argus-robot-testsuite"

TESTSUITE_REPO="${TESTSUITE_REPO:-https://github.com/argus-authz/argus-robot-testsuite}"
TESTSUITE_BRANCH="${TESTSUITE_BRANCH:-master}"
OUTPUT_REPORTS="${OUTPUT_REPORTS:-reports}"
PAP_PORT="${PAP_PORT:-8150}"
PDP_PORT="${PDP_PORT:-8152}"
PEP_PORT="${PEP_PORT:-8154}"
TIMEOUT="${TIMEOUT:-300}"


## Utility
yum update -y && \
yum install -y wget curl voms-clients myproxy voms-test-ca && \
yum clean all

## Get Puppet modules
cd /opt
rm -rfv ci-puppet-modules/ argus-mw-devel/

git clone https://github.com/cnaf/ci-puppet-modules.git && \
git clone https://github.com/argus-authz/argus-mw-devel.git


## Configure
/opt/puppetlabs/bin/puppet module install puppetlabs-stdlib
/opt/puppetlabs/bin/puppet apply --modulepath=/opt/ci-puppet-modules/modules/:/opt/argus-mw-devel/:/etc/puppetlabs/code/environments/production/modules /manifest.pp && grep -q 'failure: 0' /opt/puppetlabs/puppet/cache/state/last_run_summary.yaml


## Setup certificates
wget --no-clobber -O /etc/grid-security/hostcert.pem https://raw.githubusercontent.com/marcocaberletti/argus-deployment-test/master/certificates/__cnaf_test.cert.pem
chown root:root /etc/grid-security/hostcert.pem
chmod 0644 /etc/grid-security/hostcert.pem

wget --no-clobber -O /etc/grid-security/hostkey.pem https://raw.githubusercontent.com/marcocaberletti/argus-deployment-test/master/certificates/__cnaf_test.key.pem
chown root:root /etc/grid-security/hostkey.pem
chmod 0400 /etc/grid-security/hostkey.pem


## Wait for services and run
papctl start
echo "Wait for PAP"
set +e
wait_for_service ${HOSTNAME} ${PAP_PORT} ${TIMEOUT}

set -e
echo "PAP is ready. Start PDP"


pdpctl start
echo "Wait for PDP"
set +e
wait_for_service ${HOSTNAME} ${PDP_PORT} ${TIMEOUT}
set -e
echo "PDP is ready. Start for PEP"

pepdctl start
echo "Wait for PEP"
set +e
wait_for_service ${HOSTNAME} ${PEP_PORT} ${TIMEOUT}
set -e
echo "PEP is ready."


## Copy user certificates in default directory
cd ${HOME}
mkdir ${GLOBUS_DIR}

cp ${CERT_DIR}/test0.cert.pem ${GLOBUS_DIR}/usercert.pem
chmod 644 ${GLOBUS_DIR}/usercert.pem

echo pass > ${GLOBUS_DIR}/password
openssl rsa -in ${CERT_DIR}/test0.key.pem -out ${GLOBUS_DIR}/userkey.pem -passin file:${GLOBUS_DIR}/password
chmod 400 ${GLOBUS_DIR}/userkey.pem

cp /usr/share/igi-test-ca-2/test0.cert.pem ${GLOBUS_DIR}/iota_usercert.pem
cp /usr/share/igi-test-ca-2/test0.key.pem ${GLOBUS_DIR}/iota_userkey.pem
openssl rsa -in ${GLOBUS_DIR}/iota_userkey.pem -out ${GLOBUS_DIR}/iota_userkey.rsa.pem -passin file:${GLOBUS_DIR}/password
mv ${GLOBUS_DIR}/iota_userkey.rsa.pem ${GLOBUS_DIR}/iota_userkey.pem
chmod 0644 ${GLOBUS_DIR}/iota_usercert.pem
chmod 0400 ${GLOBUS_DIR}/iota_userkey.pem


## Clone testsuite code
if [ ! -d ${TS_DIR} ]; then
	echo "Clone argus-robot-testsuite repository ..." 
	git clone ${TESTSUITE_REPO} --branch ${TESTSUITE_BRANCH} ${TS_DIR}
fi

cd ${TS_DIR}

## Edit configuration
sed -i '/^T_PAP_HOST.*/d' env_config.py
sed -i '/^T_PDP_HOST.*/d' env_config.py
sed -i '/^T_PEP_HOST.*/d' env_config.py

echo "T_PAP_HOST='${HOSTNAME}'" >> env_config.py
echo "T_PDP_HOST='${HOSTNAME}'" >> env_config.py
echo "T_PEP_HOST='${HOSTNAME}'" >> env_config.py


## Run
echo "Run ..."
pybot --pythonpath .:lib  -d ${OUTPUT_REPORTS} --exclude=remote tests/

echo "Done."
