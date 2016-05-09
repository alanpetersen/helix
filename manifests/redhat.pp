# Class: helix::redhat
# ===========================
#
# Manages the custom yum perforce repo and installs the specified package
#
# Parameters
# ----------
#
# * `pkgname`
# This required parameter specifies the package to be installed
# * `pubkey_url`
# * `yum_baseurl`
# * `perforce_repo_name`
#
class helix::redhat (
  $pkgname,
  $pubkey_url         = $helix::params::pubkey_url,
  $yum_baseurl        = $helix::params::yum_baseurl,
  $perforce_repo_name = $helix::params::perforce_repo_name,
) inherits helix::params {

  if !defined(Yumrepo[$perforce_repo_name]) {
    yumrepo { $perforce_repo_name:
      baseurl  => $yum_baseurl,
      descr    => 'Perforce Repo',
      enabled  => '1',
      gpgcheck => '1',
      gpgkey   => $pubkey_url,
    }
  }

  if !defined(Package[$pkgname]) {
    package { $pkgname:
      ensure  => installed,
      require => Yumrepo[$perforce_repo_name],
    }
  }

}
