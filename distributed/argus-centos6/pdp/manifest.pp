include mwdevel_infn_ca
include mwdevel_test_ca

class { 'mwdevel_argus::pdp::configure':
  pap_host       => 'argus-pap-centos6.cnaf.test',
  pap_port       => 8150,
  pdp_admin_host => '0.0.0.0',
  pdp_jopts      => '-Xmx256M -Djdk.tls.trustNameService=true -Djava.security.egd=file:/dev/urandom',
}
