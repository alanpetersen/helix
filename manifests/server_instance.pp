#
define helix::server_instance (
  $p4port,
  $p4root        = "/opt/perforce/servers/${title}/root",
  $p4depots      = "/opt/perforce/servers/${title}/depots",
  $p4log         = "/var/log/perforce/${title}_server.log",
  $p4journal     = "/opt/perforce/servers/${title}/checkpoints/journal",
  $p4ssl         = "/opt/perforce/servers/${title}/ssl",
  $osuser        = 'perforce',
  $osgroup       = 'perforce',
  $ensure        = 'running',
  $enabled       = true,
) {

  $instance_name = $title

  if !defined(Class['helix::server']) {
    fail('you must declare helix::server before declaring instances')
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
  if $p4ssl == "/opt/perforce/servers/${title}/depots" and !defined(File[$p4ssl]) {
    if !defined(File["${title}_serverdir"]) {
      file { "${title}_serverdir":
        ensure  => directory,
        path    => "/opt/perforce/servers/${title}",
        require => File["${title}_p4dctl_conf"],
      }
    }

    file { "${title}_p4ssl":
      ensure  => directory,
      path    => $ssl,
      require => File["${title}_p4dctl_conf"],
      before  => Service["${title}_p4d_service"],
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

  # manage the log diretory if it is the default and not already managed
  if $p4log == "/var/log/perforce/${title}_proxy.log" and !defined(File['/var/log/perforce']) {
    file { '/var/log/perforce':
      ensure  => directory,
      require => Package[$helix::server::pkgname],
      before  => Service["${title}_p4d_service"],
    }
  }

  service { "${title}_p4d_service":
    ensure  => $ensure,
    start   => "/usr/sbin/p4dctl start ${instance_name}",
    stop    => "/usr/sbin/p4dctl stop ${instance_name}",
    restart => "/usr/sbin/p4dctl restart ${instance_name}",
    status  => "/usr/sbin/p4dctl status ${instance_name}",
    require => File["${title}_p4dctl_conf"],
  }

}
