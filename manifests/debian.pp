# Class: helix::debian
# ===========================
#
# Manages the custom debian perforce repo and installs the specified package
#
# Parameters
# ----------
#
# * `pkgname`
# This required parameter specifies the package to be installed
# * `pubkey_url`
# * `p4_key_fingerprint`
# * `p4_distro_location`
# * `p4_distro_release`
#
class helix::debian (
  $pkgname,
  $pubkey_url            = $helix::params::pubkey_url,
  $p4_key_fingerprint    = $helix::params::p4_key_fingerprint,
  $p4_distro_location    = $helix::params::p4_distro_location,
  $p4_distro_release     = $helix::params::p4_distro_release,
) inherits helix::params {

  include apt

  apt::key { 'perforce-key':
    ensure => present,
    id     => $p4_key_fingerprint,
    source => $pubkey_url,
  }

  apt::source { 'perforce-apt-config':
    comment  => 'This is the Perforce debian distribution configuration file',
    location => $p4_distro_location,
    release  => $p4_distro_release,
    repos    => 'release',
    require  => Apt::Key['perforce-key'],
    include  => {
      'src' => false,
      'deb' => true,
    },
  }

  package { $pkgname:
    ensure  => installed,
    require => Exec['apt_update'],
  }

}
