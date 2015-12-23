# Class: helix::client
# ===========================
#
# Manages the helix command-line client (p4).
#
# Parameters
# ----------
#
# * `pkgname`
# This parameter can be used to specify the package name of the helix client. The default
# value (helix-cli) is provided by the helix_cli_pkg variable in the helix::params class
#
class helix::client (
  $pkgname = $helix::params::helix_cli_pkg,
) inherits helix::params {

  helix::package { $pkgname:
    pkgname => $pkgname,
  }

}
