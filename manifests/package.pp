#
define helix::package (
  $pkgname
) {
  case $::osfamily {
    'redhat': {
      class {'helix::redhat':
        pkgname => $pkgname,
      }
    }
    'debian': {
      class {'helix::debian':
        pkgname => $pkgname,
      }
    }
    default: {
      fail("Sorry, ${::osfamily} is not currently suppported by the gitfusion module")
    }
  }
}
