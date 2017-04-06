include mwdevel_infn_ca
include mwdevel_test_ca
include mwdevel_test_ca_policies
include mwdevel_egi_trust_anchors
include mwdevel_igtf_distribution
include mwdevel_robot_framework

package { 'ca_policy_*':
  ensure  => latest,
  require => Class['mwdevel_igtf_distribution'],
}

class { 'mwdevel_argus::pap::configure':
  pap_java_opts => '-Djava.security.egd=file:/dev/urandom'
}

class { 'mwdevel_argus::pdp::configure':
  pdp_jopts => '-Xmx256M -Djdk.tls.trustNameService=true -Djava.security.egd=file:/dev/urandom'
}

class { 'mwdevel_argus::pepd::configure':
  pepd_jopts => '-Xmx256M -Djdk.tls.trustNameService=true -Djava.security.egd=file:/dev/urandom'
}

include mwdevel_argus::bdii::configure
include mwdevel_argus::clients
