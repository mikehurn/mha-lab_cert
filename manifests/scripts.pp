# Manage the lab_cert scripts.
class lab_cert::scripts {

  include lab_cert::params

  $cert_share       = $lab_cert::cert_share
  $cert_dir         = $lab_cert::cert_dir
  $checkend_seconds = $lab_cert::params::checkend_days * 86400
  $key_dir          = $lab_cert::params::key_dir
  $crt_dir          = $lab_cert::params::crt_dir
  $meta_dir         = "${lab_cert::params::crt_dir}/meta"

  case $::operatingsystem {
    'CentOS': {

      # Setup utility scripts.
      file { '/usr/local/sbin/lab_cert_mount.sh':
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template("${module_name}/lab_cert_mount.sh.erb"),
      }

      file { '/usr/local/sbin/lab_cert_umount.sh':
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template("${module_name}/lab_cert_umount.sh.erb"),
      }

      file { '/usr/local/sbin/managecerts.sh':
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template("${module_name}/managecerts.sh.erb"),
      }

      file { '/usr/local/sbin/managekeys.sh':
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template("${module_name}/managekeys.sh.erb"),
      }

    }
    default: {
      fail("${::hostname}: This module does not support operatingsystem ${::operatingsystem}")
    }
  }
}

