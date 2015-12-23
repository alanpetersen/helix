# Class: helix::proxy
# ===========================
#
# Manages the helix proxy (p4p).
#
# Parameters
# ----------
#
# * `pkgname`
# This parameter can be used to specify the package name of the helix proxy. The default
# value (helix-proxy) is provided by the helix_proxy_pkg variable in the helix::params class
#
class helix::proxy (
  $pkgname = $helix::params::helix_proxy_pkg,
) inherits helix::params  {

  helix::package { $pkgname:
    pkgname => $pkgname,
  }

}
