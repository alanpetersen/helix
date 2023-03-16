#
# @summary
#   This class contains parameters and variables used by the other classes in the Helix module.
#
# @param p4_key_fingerprint [String]
#   The fingerprint of the Perforce public key. This value may need to be updated if
#   Perforce updates the public key. # @param pubkey_url [String]
#   The URL for the Perforce public key.
# @param perforce_package_url [String]
#   The base URL for the Perforce package repository.
# @param helix_cli_pkg [String]
#   The package name for the Helix CLI tool.
# @param helix_broker_pkg [String]
#   The package name for the Helix broker (p4broker).
# @param helix_proxy_pkg [String]
#   The package name for the Helix proxy.
# @param helix_p4d_pkg [String]
#   The package name for the Helix server (p4d).
#
class helix::params {
  #these values would need to be updated if Perforce updates the public key
  $p4_key_fingerprint   = 'E58131C0AEA7B082C6DC4C937123CB760FF18869'
  $pubkey_url           = 'https://package.perforce.com/perforce.pubkey'
  $perforce_package_url = 'http://package.perforce.com'
  $helix_cli_pkg        = 'helix-cli'
  $helix_broker_pkg     = 'helix-broker'
  $helix_proxy_pkg      = 'helix-proxy'
  $helix_p4d_pkg        = 'helix-p4d'

  case $facts['os']['family'] {
    'redhat': {
      if !($facts['os']['release']['major'] in ['6','7']) {
        fail('Sorry, only releases 6 and 7 are currently suppported by the helix module')
      }
      $perforce_repo_name = 'perforce'
      $yum_baseurl        = "${perforce_package_url}/yum/rhel/${facts['os']['release']['major']}/x86_64"
      $p4dctl             = '/usr/sbin/p4dctl'
    }
    'debian': {
      if !($facts['os']['distro']['codename'] in ['precise','trusty']) {
        fail('Sorry, only the precise or trusty distros are currently suppported by the helix module')
      }
      $p4_distro_location = "${perforce_package_url}/apt/ubuntu"
      $p4_distro_release  = $facts['os']['distro']['codename']
      $p4dctl             = '/usr/bin/p4dctl'
    }
    default: {
      fail("Sorry, ${facts['os']['family']} is not currently suppported by the helix module")
    }
  }
}
