#!/bin/bash

set -xe

# Get Puppet modules
cd /opt
rm -rfv ci-puppet-modules/ argus-mw-devel/

git clone https://github.com/cnaf/ci-puppet-modules.git
git clone https://github.com/argus-authz/argus-mw-devel.git

cd /

## Configure
/opt/puppetlabs/bin/puppet module install puppetlabs-stdlib
/opt/puppetlabs/bin/puppet apply --modulepath=/opt/ci-puppet-modules/modules/:/opt/argus-mw-devel/:/etc/puppetlabs/code/environments/production/modules/ /manifest.pp && \
	grep -q 'failure: 0' /opt/puppetlabs/puppet/cache/state/last_run_summary.yaml

## Setup certificates
wget --no-clobber -O /etc/grid-security/hostcert.pem https://raw.githubusercontent.com/marcocaberletti/argus-deployment-test/master/certificates/__cnaf_test.cert.pem
chown root:root /etc/grid-security/hostcert.pem
chmod 0644 /etc/grid-security/hostcert.pem

wget --no-clobber -O /etc/grid-security/hostkey.pem https://raw.githubusercontent.com/marcocaberletti/argus-deployment-test/master/certificates/__cnaf_test.key.pem
chown root:root /etc/grid-security/hostkey.pem
chmod 0400 /etc/grid-security/hostkey.pem

## wait for PDP before start
set +e
start_ts=$(date +%s)
timeout=300
sleeped=0
while true; do
    (echo > /dev/tcp/$PDP_HOST/$PDP_PORT) >/dev/null 2>&1
    result=$?
    if [[ $result -eq 0 ]]; then
        end_ts=$(date +%s)
        echo "$PDP_HOST:$PDP_PORT is available after $((end_ts - start_ts)) seconds"
        break
    fi
    echo "Waiting for PDP"
    sleep 5

    sleeped=$((sleeped+5))
    if [ $sleeped -ge $timeout  ]; then
    	echo "Timeout!"
    	exit 1
	fi
done
set -e

# Run
pepdctl start

sleep 5

tail -f /var/log/argus/pepd/*.log
