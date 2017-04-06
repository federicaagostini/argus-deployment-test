#!/bin/bash

set -xe

# Get Puppet modules
cd /opt
rm -rfv ci-puppet-modules/ argus-mw-devel/

git clone https://github.com/cnaf/ci-puppet-modules.git
git clone https://github.com/argus-authz/argus-mw-devel.git

cd /

## Configure
puppet module install puppetlabs-stdlib
puppet apply --modulepath=/opt/ci-puppet-modules/modules/:/opt/argus-mw-devel/:/etc/puppet/modules/ /manifest.pp

## Setup certificates
wget --no-clobber -O /etc/grid-security/hostcert.pem https://raw.githubusercontent.com/marcocaberletti/argus-deployment-test/master/certificates/__cnaf_test.cert.pem
chown root:root /etc/grid-security/hostcert.pem
chmod 0644 /etc/grid-security/hostcert.pem

wget --no-clobber -O /etc/grid-security/hostkey.pem https://raw.githubusercontent.com/marcocaberletti/argus-deployment-test/master/certificates/__cnaf_test.key.pem
chown root:root /etc/grid-security/hostkey.pem
chmod 0400 /etc/grid-security/hostkey.pem


# Run
papctl start

sleep 5

tail -f /var/log/argus/pap/*.log
