# == Class: lab_cert
#
# Class manages openssl installation, and certificate/key/csr generation
class lab_cert (
  $cert_share = 'lab-ca.example.com:/Certificates',
  $cert_dir = '/tmp',
) {

  include lab_cert::params
  include lab_cert::scripts

  file { "${lab_cert::params::crt_dir}/meta":
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0444',
  }

  # These calls to make a certificate should now come from the app that needs them.
  # I.e. nginx, appache.
  # But can be used for testing. The next two lines will also 'make' a citificate for this host.
  lab_cert::cert { $::fqdn:
    alt_names => [ $::hostname ],
  }

  # Note: the lab_cert::cert class will add our CN to the alt_names list

  #lab_cert::cert { 'www.example.com':
  #  alt_names => [ 'www2.example.com' ],
  #  country   => 'US',
  #  org       => 'Example.com, LLC',
  #  org_unit  => 'Web Team',
  #  state     => 'CA',
  #}

}
