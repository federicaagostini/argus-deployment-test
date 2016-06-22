#!/bin/bash

set -xe

cd /opt
rm -rfv *puppet*

git clone https://github.com/cnaf/ci-puppet-modules.git
git clone https://github.com/marcocaberletti/puppet.git

cd /

# Configure
puppet module install puppetlabs-stdlib
puppet apply --modulepath=/opt/ci-puppet-modules/modules/:/opt/puppet/modules/:/etc/puppet/modules/ /manifest.pp

/etc/init.d/bdii restart

sleep 5

tail -f /var/log/bdii/bdii-update.log