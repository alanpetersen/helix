#
define helix::broker_instance (
  $p4brokerport,
  $p4brokertarget,
  $directory     = "/opt/perforce/servers/${title}",
  $logfile       = "/var/log/perforce/${title}_broker.log",
  $debuglevel    = '1',
  $adminname     = 'Perforce Admins',
  $adminphone    = '999/911',
  $adminemail    = 'perforce-admins@example.com',
  $serviceuser   = undef,
  $ticketfile    = undef,
  $redirection   = 'selective',
  $commands      = [],
  $osuser        = 'perforce',
  $osgroup       = 'perforce',
  $ensure        = 'running',
  $enabled       = true,
) {

  $instance_name = $title

  if !defined(Class['helix::broker']) {
    fail('you must declare helix::broker before declaring instances')
  }

  File {
    ensure => file,
    owner  => $osuser,
    group  => $osgroup,
    mode   => '0644',
  }

  # manage the log directory if not the default
  if $logfile == "/var/log/perforce/${title}_broker.log" and !defined(File['/var/log/perforce']) {
    file { '/var/log/perforce':
      ensure  => directory,
      require => Package[$helix::broker::pkgname],
    }
  }

  # manage the p4dctl config file
  file { "${title}_p4dctl_conf":
    path    => "/etc/perforce/p4dctl.conf.d/p4broker_${instance_name}.conf",
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('helix/p4broker_p4dctl.erb'),
    require => Package[$helix::broker::pkgname],
  }

  # manage the parent directory if it is the default
  if $directory == "/opt/perforce/servers/${title}" {
    file { "${title}_conf_dir":
      ensure  => directory,
      path    => $directory,
      require => File["${title}_p4dctl_conf"],
    }
  }

  file { "${title}_broker.conf":
    path    => "${directory}/broker.conf",
    content => template('helix/p4broker_conf.erb'),
  }

  service { "${title}_p4broker_service":
    ensure  => $ensure,
    start   => "/usr/sbin/p4dctl start ${instance_name}",
    stop    => "/usr/sbin/p4dctl stop ${instance_name}",
    restart => "/usr/sbin/p4dctl restart ${instance_name}",
    status  => "/usr/sbin/p4dctl status ${instance_name}",
    require => File["${title}_broker.conf"],
  }

}
