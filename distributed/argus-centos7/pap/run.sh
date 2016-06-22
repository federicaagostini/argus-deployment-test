#!/bin/bash

set -xe

# Get Puppet modules
cd /opt
rm -rfv *puppet*

git clone https://github.com/cnaf/ci-puppet-modules.git
git clone https://github.com/marcocaberletti/puppet.git

# Configure
puppet module install puppetlabs-stdlib
puppet apply --modulepath=/opt/ci-puppet-modules/modules/:/opt/puppet/modules/:/etc/puppet/modules/ /manifest.pp

cd /

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