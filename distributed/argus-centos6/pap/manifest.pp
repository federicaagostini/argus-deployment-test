include mwdevel_infn_ca
include mwdevel_test_ca

class { 'mwdevel_argus::pap::configure': pap_java_opts => '-Djava.security.egd=file:/dev/urandom', }
