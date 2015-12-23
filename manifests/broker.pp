# Class: helix::broker
# ===========================
#
# Manages the helix broker (p4broker).
#
# Parameters
# ----------
#
# * `pkgname`
# This parameter can be used to specify the package name of the helix broker. The default
# value (helix-broker) is provided by the helix_broker_pkg variable in the helix::params class
#
class helix::broker (
  $pkgname = $helix::params::helix_broker_pkg,
) inherits helix::params  {

  helix::package { $pkgname:
    pkgname => $pkgname,
  }

}
