#
define helix::proxy_instance (
  $p4proxyport,
  $p4proxytarget,
  $cachedir      = "/opt/perforce/servers/${title}/cache",
  $p4ssl         = "/opt/perforce/servers/${title}/ssl",
  $logfile       = "/var/log/perforce/${title}_proxy.log",
  $osuser        = 'perforce',
  $osgroup       = 'perforce',
  $ensure        = 'running',
  $enabled       = true,
) {

  $instance_name = $title

  if !defined(Class['helix::proxy']) {
    fail('you must declare helix::proxy before declaring instances')
  }

  File {
    ensure => file,
    owner  => $osuser,
    group  => $osgroup,
    mode   => '0644',
  }

  if $logfile == "/var/log/perforce/${title}_proxy.log" and !defined(File['/var/log/perforce']) {
    file { '/var/log/perforce':
      ensure  => directory,
      require => Package[$helix::proxy::pkgname],
    }
  }

  # manage the p4dctl config file
  file { "${title}_p4dctl_conf":
    path    => "/etc/perforce/p4dctl.conf.d/p4proxy_${instance_name}.conf",
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('helix/p4proxy_p4dctl.erb'),
    require => Package[$helix::proxy::pkgname],
  }

  # manage the cache directory if it is the default
  if $cachedir == "/opt/perforce/servers/${title}/cache" {
    if !defined(File["${title}_conf_dir"]) {
      file { "${title}_serverdir":
        ensure  => directory,
        path    => "/opt/perforce/servers/${title}",
        require => File["${title}_p4dctl_conf"],
      }
    }

    file { "${title}_cachedir":
      ensure  => directory,
      path    => $cachedir,
      require => File["${title}_p4dctl_conf"],
      before  => Service["${title}_p4proxy_service"],
    }
  }

  # manage the p4ssl directory if it is the default and not already managed
  if $p4ssl == "/opt/perforce/servers/${title}/ssl" {
    if !defined(File["${title}_conf_dir"]) {
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
      before  => Service["${title}_p4proxy_service"],
    }
  }

  # if broker is going to listen on SSL port, ensure that certificate is generated
  if $p4brokerport =~ /^ssl:/ {
    exec { "${title}-Gc":
      command     => '/usr/sbin/p4p -Gc',
      user        => $osuser,
      environment => "P4SSLDIR=${p4ssl}",
      creates     => "${p4ssl}/privatekey.txt",
      require     => File[$p4ssl],
      notify      => Exec["${title}-Gf"],
      before      => Service["${title}_p4proxy_service"],
    }
    exec { "${title}-Gf":
      command     => '/usr/sbin/p4p -Gf',
      user        => $osuser,
      environment => "P4SSLDIR=${p4ssl}",
      refreshonly => true,
    }
  }

  # manage the service. The actual service is `perforce-p4dctl`, but the p4dctl command
  # is used to manage the various service instances. it provides start/stop/restart/status
  # subcommands to manage the instance
  service { "${title}_p4proxy_service":
    ensure  => $ensure,
    start   => "/usr/sbin/p4dctl start ${instance_name}",
    stop    => "/usr/sbin/p4dctl stop ${instance_name}",
    restart => "/usr/sbin/p4dctl restart ${instance_name}",
    status  => "/usr/sbin/p4dctl status ${instance_name}",
    require => File["${title}_p4dctl_conf"],
  }

}
