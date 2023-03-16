# @summary Install a package on different Linux distributions
#
# @param pkgname [String] The name of the package to install
#
define helix::package (
  $pkgname
) {
  case $facts['os']['family'] {
    'redhat': {
      class { 'helix::redhat':
        pkgname => $pkgname,
      }
    }
    'debian': {
      class { 'helix::debian':
        pkgname => $pkgname,
      }
    }
    default: {
      fail("Sorry, ${facts['os']['family']} is not currently suppported by the gitfusion module")
    }
  }
}
