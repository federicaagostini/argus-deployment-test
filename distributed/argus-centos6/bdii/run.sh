#!/bin/bash

set -xe

cd /opt
rm -rfv ci-puppet-modules/ argus-mw-devel/

git clone https://github.com/cnaf/ci-puppet-modules.git
git clone https://github.com/argus-authz/argus-mw-devel.git

cd /

## Configure
/opt/puppetlabs/bin/puppet module install puppetlabs-stdlib
/opt/puppetlabs/bin/puppet apply --modulepath=/opt/ci-puppet-modules/modules/:/opt/argus-mw-devel/:/etc/puppetlabs/code/environments/production/modules/ /manifest.pp && \
	grep -q 'failure: 0' /opt/puppetlabs/puppet/cache/state/last_run_summary.yaml

/etc/init.d/bdii start

sleep 5

tail -f /var/log/bdii/bdii-update.log
