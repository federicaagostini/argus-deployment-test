include puppet-infn-ca
include puppet-test-ca
include puppet-robot-framework

class { 'argus::pap::configure': pap_java_opts => '-Djava.security.egd=file:/dev/urandom' }

class { 'argus::pdp::configure': pdp_jopts => '-Xmx256M -Djdk.tls.trustNameService=true -Djava.security.egd=file:/dev/urandom' }

class { 'argus::pepd::configure': pepd_jopts => '-Xmx256M -Djdk.tls.trustNameService=true -Djava.security.egd=file:/dev/urandom' }

include argus::bdii::configure
include argus::clients
