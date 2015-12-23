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

  case $::osfamily {
    'redhat': {
      if !($::operatingsystemmajrelease in ['6','7']) {
        fail('Sorry, only releases 6 and 7 are currently suppported by the helix module')
      }
      $perforce_repo_name = 'perforce'
      $yum_baseurl        = "${perforce_package_url}/yum/rhel/${::operatingsystemmajrelease}/x86_64"
    }
    'debian': {
      if !($::lsbdistcodename in ['precise','trusty']) {
        fail('Sorry, only the precise or trusty distros are currently suppported by the helix module')
      }
      $p4_distro_location = "${perforce_package_url}/apt/ubuntu"
      $p4_distro_release  = $::lsbdistcodename
    }
    default: {
      fail("Sorry, ${::osfamily} is not currently suppported by the helix module")
    }
  }

}
