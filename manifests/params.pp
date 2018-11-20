# == Class: lab_cert::params
# Sets up some params based on OSFamily for the remainder of the module to make
# use of
class lab_cert::params (
  $checkend_days = 35
) {

  case $::osfamily {
    'RedHat': {
      $crt_dir = '/etc/pki/tls/certs'
      $key_dir = '/etc/pki/tls/private'
    }
    default: {
      fail("\$::osfamily = '${::osfamily}' not supported!")
    }
  }
}
