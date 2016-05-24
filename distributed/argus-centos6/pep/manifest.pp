include puppet-infn-ca
include puppet-test-ca

class { 'argus::pepd::configure':
  pdp_host   => 'argus-pdp-centos6.cnaf.test',
  pdp_port   => 8152,
  use_secondary_group_names_for_mapping => true,
  pepd_jopts => '-Xmx256M -Djdk.tls.trustNameService=true -Djava.security.egd=file:/dev/urandom'
}
