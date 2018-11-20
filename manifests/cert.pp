# == Define: lab_cert::cert
#
# Setups up the necessary components for an SSL certificate, including
# the private key and CSR. If any names are
# provided for the alt_names parameter, a SAN (Subject Alternative Name)
# request will be generated.
#
#
# === Parameters:
# [*cn*]
#   Primary common name.  Defaults to the name of the resource.
#
# [*country*]
#   2-letter country code
#
# [*state*]
#   State name
#
# [*city*]
#   City name
#
# [*org*]
#   Organization Name
#
# [*org_unit*]
#   Organization Unit Name
#
# [*alt_names*]
#   Array of alternate DNS names
#
# === Original Author:
#   Aaron Russo <arusso@berkeley.edu>
#
# === This version Mike Hurn >mike< [@] >hurn.ca<
#
define lab_cert::cert(
  $country   = 'CA',
  $state     = 'Ontario',
  $city      = 'Ottawa',
  $org       = 'Example',
  $org_unit  = 'Certificate Administration',
  $caemail   = 'cert_admin@example.com',
  $alt_names = ['']
) {

  include lab_cert
  include lab_cert::params
  include lab_cert::scripts

  $hostname_regex = '^(?i:)(((([a-z0-9][-a-z0-9]{0,61})?[a-z0-9])[.])*([a-z][-a-z0-9]{0,61}[a-z0-9]|[a-z])[.]?)$'

  validate_re( $country, '^[A-Z]{2}$' )
  validate_re( $state, '^(?i)[A-Z]+$' )
  validate_re( $city, '^(?i)[A-Z ]+$' )
  validate_string( $org )
  validate_string( $org_unit )
  validate_array( $alt_names )

  # Add our CN to the alt_names list
  $alt_names_real = flatten( unique( [ $name, $alt_names ] ) )

  $checkend_seconds = $lab_cert::params::checkend_days * 86400

  $key_dir          = $lab_cert::params::key_dir
  $crt_dir          = $lab_cert::params::crt_dir
  $meta_dir         = "${lab_cert::params::crt_dir}/meta"

  $key_file         = "${lab_cert::params::key_dir}/${name}.key"
  $secure_key_file  = "${lab_cert::params::key_dir}/${name}.secure.key"
  $cnf_file         = "${lab_cert::params::crt_dir}/meta/${name}.cnf"
  $csr_file         = "${lab_cert::params::crt_dir}/meta/${name}.csr"
  $crt_file         = "${lab_cert::params::crt_dir}/${name}.crt"

  case $::operatingsystem {
    'CentOS': {

      # Generate our config file
      # This can change as we change SAN names and the whatnot. This should trigger
      # the re-generation of a CSR but NOT the CRT or the KEY since we dont want
      # it overwriting a legit cert or key.  We'll let the installation classes
      # handle updating the certs
      # We will need to review this when our certs expire or we start using a new CA. MEH.
      file { $cnf_file:
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0440',
        content => template('lab_cert/host.cnf.erb'),
        before  => Exec["manage-cert-${name}"],
      }

      # If the key file is missing we first try and get a copy from the CA Store.
      # If that fails we generate a new key.
      # this should only happen once, ever!

      exec { "manage-key-${name}":
        command   => "/usr/local/sbin/managekeys.sh ${name}",
        path      => [ '/bin', '/usr/bin' ],
        unless    => ["test -f ${key_file}"],
        require   => [ File["${lab_cert::params::crt_dir}/meta"], File['/usr/local/sbin/managekeys.sh'] ],
        logoutput => true,
      }

      # The helper script 'managecerts.sh' does most of the work it:
      # Will try and copy a cert from our CA store.
      # If that fails it will:
      # * generate a CSR and copy them to our CA store.
      # * The script then wates for the CA to sign the CSR and grenerate a cert.
      # * It then copies the cert back to the local host.

      exec { "manage-cert-${name}":
        command   => "/usr/local/sbin/managecerts.sh ${name}",
        path      => [ '/bin', '/usr/bin' ],
        unless    => ["/usr/bin/openssl x509 -in ${crt_file}  -noout -checkend ${checkend_seconds} 2>/dev/null"],
        require   => [ Exec["manage-key-${name}"], File['/usr/local/sbin/managecerts.sh'] ],
        logoutput => true,
      }

    }
    default: {
      fail("${::hostname}: This module does not support operatingsystem ${::operatingsystem}")
    }
  }
}

