# Author::    Paul Stack  (mailto:pstack@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: nsclient::install
#
# This private class is meant to be called from `nsclient`.
# It downloads the package and installs it.
#
class nsclient::install {

  validate_string($nsclient::package_source_location)
  validate_string($nsclient::package_source)
  validate_string($nsclient::package_name)

  $source = "${nsclient::package_source_location}/${nsclient::package_source}"

  case downcase($::osfamily) {
    'windows': {

      if ! defined(File[$nsclient::download_destination]) {
        file { $nsclient::download_destination:
          ensure => directory,
        }
      }

      download_file { 'NSCP-Installer':
        url                   => $source,
        destination_directory => $nsclient::download_destination,
        require               => File[$nsclient::download_destination],
        proxyAddress          => $nsclient::proxy_server
      }

      package { $nsclient::package_name:
        ensure   => installed,
        source   => "${nsclient::download_destination}\\${nsclient::package_source}",
        provider => 'windows',
        require  => Download_file['NSCP-Installer']
      }
    }
    default: {
      fail('This module only works on Windows based systems.')
    }
  }
}
