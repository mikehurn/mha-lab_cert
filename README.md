
# lab_cert

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with lab_cert](#setup)
    * [What lab_cert affects](#what-lab_cert-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with lab_cert](#beginning-with-lab_cert)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

The mha-lab_cert module is the companion module to mha-lab_ca a SSL Certificate Authority for Lab and development environments.

In use the mha-lab_cert module takes a FQDN or a CNAME with or without an Array of alternate DNS names. 
Then generate x509 key and csr file. It then sends the csr to lab_ca for signing and retrives the signed certificate.

Please exercise caution if you use this module it was designed be simple and usable. With limited security measures. 
The design goal is to be able generate 'in house' certificates that can be used in web browsers and for server to server communications.


## Setup

### Setup Requirements

At the minimum update (in init.pp) the following from the defaults!
```
  $cert_share = 'lab-ca.example.com:/Certificates',
```

In lab_cert::cert you may want to change the following:
```
  $country   = 'CA',
  $state     = 'Ontario',
  $city      = 'Ottawa',
  $org       = 'Example',
  $org_unit  = 'Certificate Administration',
  $caemail   = 'cert_admin@example.com',
```

Note: The Server that runs lab_ca NFS exports a CA Store.
```
  $certs_nfs        = '/srv/nfs'
  $certs_base       = "${certs_nfs}/Certificates"
```

The lab_cert helper scripts will mount and umount $cert_share as needed.

### Beginning with lab_cert

  # Note: the lab_cert::cert class will add our CN to the alt_names list
```
  lab_cert::cert { 'www.example.com':
    alt_names => [ 'www2.example.com' ],
    country   => 'US',
    org       => 'Example.com, LLC',
    org_unit  => 'Web Team',
    state     => 'CA',
  }
```

## Reference

This Puppet module is in part based on arusso/ssl by: Aaron Russo.
From original it has had a lot of changes...

## Limitations

Developed and tested on CentOS 7.5. But should be good for RHEL 7.x.
Also with Puppet 5.5 and Foreman for the GUI. (See theforeman.org)

## Development

At the moment please email suggestions to the code and default config files.

Note: At the moment this code is in the early stages of development it still needs a few enhancements. As time permits or a need crops up I plan to look into them.

