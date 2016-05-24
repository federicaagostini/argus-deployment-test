include puppet-infn-ca
include puppet-test-ca

class { 'argus::pap::configure': pap_java_opts => '-Djava.security.egd=file:/dev/urandom' }
