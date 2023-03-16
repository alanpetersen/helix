# Class: helix::server
# ===========================
#
# Manages the helix server (p4d).
#
# Parameters
# ----------
#
# * `pkgname`
# This parameter can be used to specify the package name of the helix server. The default
# value (helix-p4d) is provided by the helix_p4d_pkg variable in the helix::params class
#
class helix::server (
  $pkgname = $helix::params::helix_p4d_pkg,
) inherits helix::params {
  helix::package { $pkgname:
    pkgname => $pkgname,
  }
}
