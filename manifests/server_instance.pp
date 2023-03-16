# @summary Defines a Helix server instance.
#
# @param p4port [String]: The Perforce server port number (e.g., "1666").
# @param p4root [String]: The root directory of the Perforce server instance (default: "/opt/perforce/servers/<instance_name>/root").
# @param p4depots [String]: The depots directory of the Perforce server instance (default: "/opt/perforce/servers/<instance_name>/depots").
# @param p4log [String]: The path to the Perforce server log file (default: "/var/log/perforce/<instance_name>_server.log").
# @param p4journal [String]: The path to the Perforce server journal file (default: "/opt/perforce/servers/<instance_name>/checkpoints/journal").
# @param p4ssl [String]: The path to the Perforce server SSL directory (default: "/opt/perforce/servers/<instance_name>/ssl").
# @param osuser [String]: The name of the user who owns the Perforce server instance files (default: "perforce").
# @param osgroup [String]: The name of the group that owns the Perforce server instance files (default: "perforce").
# @param ensure [String]: Whether the service should be running or stopped (default: "running").
# @param enabled [Boolean]: Whether the instance should be enabled (default: true).
# @param p4dctl Optional[[String]]: The path to the `p4dctl` command (default: `undef`).
#
# @return None
#
define helix::server_instance (
  String $p4port,
  String $p4root        = "/opt/perforce/servers/${title}/root",
  String $p4depots      = "/opt/perforce/servers/${title}/depots",
  String $p4log         = "/var/log/perforce/${title}_server.log",
  String $p4journal     = "/opt/perforce/servers/${title}/checkpoints/journal",
  String $p4ssl         = "/opt/perforce/servers/${title}/ssl",
  String $osuser        = 'perforce',
  String $osgroup       = 'perforce',
  String $ensure        = 'running',
  Boolean $enabled      = true,
  Optional[String] $p4dctl = undef,
) {
  $instance_name = $title

  if !defined(Class['helix::server']) {
    fail('you must declare helix::server before declaring instances')
  }

  if !is_bool($enabled) {
    fail('enabled parameter must be a boolean')
  }

  if !($ensure in ['running', 'stopped']) {
    fail('ensure must be set to either running or stopped')
  }

  if $p4dctl {
    $p4dctl_path = $p4dctl
  } else {
    $p4dctl_path = $helix::params::p4dctl
  }

  File {
    ensure => file,
    owner  => $osuser,
    group  => $osgroup,
    mode   => '0644',
  }

  # manage the p4dctl config file
  file { "${title}_p4dctl_conf":
    path    => "/etc/perforce/p4dctl.conf.d/p4d_${instance_name}.conf",
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('helix/p4d_p4dctl.erb'),
    require => Package[$helix::server::pkgname],
  }

  # manage the p4root directory if it is the default and not already managed
  if $p4root == "/opt/perforce/servers/${title}/root" and !defined(File[$p4root]) {
    if !defined(File["${title}_serverdir"]) {
      file { "${title}_serverdir":
        ensure  => directory,
        path    => "/opt/perforce/servers/${title}",
        require => File["${title}_p4dctl_conf"],
      }
    }

    file { "${title}_p4root":
      ensure  => directory,
      path    => $p4root,
      require => File["${title}_p4dctl_conf"],
      before  => Service["${title}_p4d_service"],
    }
  }

  # manage the p4depots directory if it is the default and not already managed
  if $p4depots == "/opt/perforce/servers/${title}/depots" and !defined(File[$p4depots]) {
    if !defined(File["${title}_serverdir"]) {
      file { "${title}_serverdir":
        ensure  => directory,
        path    => "/opt/perforce/servers/${title}",
        require => File["${title}_p4dctl_conf"],
      }
    }

    file { "${title}_p4depots":
      ensure  => directory,
      path    => $p4depots,
      require => File["${title}_p4dctl_conf"],
      before  => Service["${title}_p4d_service"],
    }
  }

  # manage the p4ssl directory if it is the default and not already managed
  if $p4ssl == "/opt/perforce/servers/${title}/ssl" {
    if !defined(File["${title}_serverdir"]) {
      file { "${title}_serverdir":
        ensure  => directory,
        path    => "/opt/perforce/servers/${title}",
        require => File["${title}_p4dctl_conf"],
      }
    }
  }

  if !defined(File[$p4ssl]) {
    file { $p4ssl:
      ensure  => directory,
      mode    => '0700',
      require => File["${title}_p4dctl_conf"],
      before  => Service["${title}_p4d_service"],
    }
  }

  # if server is going to listen on SSL port, ensure that certificate is generated
  if $p4port =~ /^ssl:/ {
    exec { "${title}-Gc":
      command     => '/usr/sbin/p4d -Gc',
      user        => $osuser,
      environment => "P4SSLDIR=${p4ssl}",
      creates     => "${p4ssl}/privatekey.txt",
      require     => File[$p4ssl],
      notify      => Exec["${title}-Gf"],
      before      => Service["${title}_p4d_service"],
    }
    exec { "${title}-Gf":
      command     => '/usr/sbin/p4d -Gf',
      user        => $osuser,
      environment => "P4SSLDIR=${p4ssl}",
      refreshonly => true,
    }
  }

  # manage the journal parent directory if it is the default and not already managed
  if $p4journal == "/opt/perforce/servers/${title}/checkpoints/journal" and !defined(File["/opt/perforce/servers/${title}/checkpoints"]) {
    if !defined(File["${title}_serverdir"]) {
      file { "${title}_serverdir":
        ensure  => directory,
        path    => "/opt/perforce/servers/${title}",
        require => File["${title}_p4dctl_conf"],
      }
    }

    file { "${title}_p4checkpoints":
      ensure  => directory,
      path    => "/opt/perforce/servers/${title}/checkpoints",
      require => File["${title}_p4dctl_conf"],
      before  => Service["${title}_p4d_service"],
    }
  }

  # manage the log directory if it is the default and not already managed
  if $p4log == "/var/log/perforce/${title}_proxy.log" and !defined(File['/var/log/perforce']) {
    file { '/var/log/perforce':
      ensure  => directory,
      require => Package[$helix::server::pkgname],
      before  => Service["${title}_p4d_service"],
    }
  }

  # manage the service. The actual service is `perforce-p4dctl`, but the p4dctl command
  # is used to manage the various service instances. it provides start/stop/restart/status
  # subcommands to manage the instance
  service { "${title}_p4d_service":
    ensure  => $ensure,
    start   => "${p4dctl_path} start ${instance_name}",
    stop    => "${p4dctl_path} stop ${instance_name}",
    restart => "${p4dctl_path} restart ${instance_name}",
    status  => "${p4dctl_path} status ${instance_name}",
    require => File["${title}_p4dctl_conf"],
  }
}
