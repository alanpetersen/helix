# @summary Defines a Helix broker instance
#
# @param p4brokerport [String] The broker's P4PORT value
# @param p4brokertarget [String] The target server's P4PORT value
# @param directory [String] (Optional) The directory where the broker instance should be installed.
#   Defaults to "/opt/perforce/servers/${title}"
# @param p4ssl [String] (Optional) The directory where SSL certificates will be stored.
#   Defaults to "/opt/perforce/servers/${title}/ssl"
# @param logfile [String] (Optional) The path to the broker instance's log file.
#   Defaults to "/var/log/perforce/${title}_broker.log"
# @param debuglevel [Integer] (Optional) The debug level for the broker instance. Defaults to 1.
# @param adminname [String] (Optional) The name of the administrator for the broker instance.
#   Defaults to "Perforce Admins"
# @param adminphone [String] (Optional) The phone number for the administrator of the broker instance.
#   Defaults to "999/911"
# @param adminemail [String] (Optional) The email address for the administrator of the broker instance.
#   Defaults to "perforce-admins@example.com"
# @param serviceuser [String] (Optional) The user under which the broker service should run.
# @param ticketfile [String] (Optional) The path to the ticket file for the broker instance.
# @param redirection [String] (Optional) The redirection mode for the broker instance.
#   Defaults to "selective"
# @param commands [Array[String]] (Optional) An array of commands to execute when the broker instance starts up.
# @param osuser [String] (Optional) The user under which to run the broker instance.
#   Defaults to "perforce"
# @param osgroup [String] (Optional) The group under which to run the broker instance.
#   Defaults to "perforce"
# @param ensure [String] (Optional) Whether the broker instance should be running or stopped.
#   Defaults to "running"
# @param enabled [Boolean] (Optional) Whether the broker instance should be enabled.
#   Defaults to true.
# @param p4dctl [String] (Optional) The path to the p4dctl command. Defaults to the value
#   defined in the helix::params class.
#
define helix::broker_instance (
  String $p4brokerport,
  String $p4brokertarget,
  String $directory     = "/opt/perforce/servers/${title}",
  String $p4ssl         = "/opt/perforce/servers/${title}/ssl",
  String $logfile       = "/var/log/perforce/${title}_broker.log",
  Integer $debuglevel    = '1',
  String $adminname     = 'Perforce Admins',
  String $adminphone    = '999/911',
  String $adminemail    = 'perforce-admins@example.com',
  Optional[String] $serviceuser   = undef,
  Optional[String] $ticketfile    = undef,
  String $redirection   = 'selective',
  Array[String] $commands      = [],
  String $osuser        = 'perforce',
  String $osgroup       = 'perforce',
  String $ensure        = 'running',
  Boolean $enabled       = true,
  Optional[String] $p4dctl        = undef,
) {
  $instance_name = $title

  if !defined(Class['helix::broker']) {
    fail('you must declare helix::broker before declaring instances')
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

  # manage the parent directory if it is the default and not already managed
  if $directory == "/opt/perforce/servers/${title}" and !defined(File["${title}_conf_dir"]) {
    file { "${title}_conf_dir":
      ensure  => directory,
      path    => $directory,
      require => File["${title}_p4dctl_conf"],
    }
  }

  # manage the p4ssl directory if it is the default and not already managed
  if $p4ssl == "/opt/perforce/servers/${title}/ssl" {
    if !defined(File["${title}_conf_dir"]) {
      file { "${title}_conf_dir":
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
      before  => Service["${title}_p4broker_service"],
    }
  }

  # if broker is going to listen on SSL port, ensure that certificate is generated
  if $p4brokerport =~ /^ssl:/ {
    exec { "${title}-Gc":
      command     => '/usr/sbin/p4broker -Gc',
      user        => $osuser,
      environment => "P4SSLDIR=${p4ssl}",
      creates     => "${p4ssl}/privatekey.txt",
      require     => File[$p4ssl],
      notify      => Exec["${title}-Gf"],
      before      => Service["${title}_p4broker_service"],
    }
    exec { "${title}-Gf":
      command     => '/usr/sbin/p4broker -Gf',
      user        => $osuser,
      environment => "P4SSLDIR=${p4ssl}",
      refreshonly => true,
    }
  }

  file { "${title}_broker.conf":
    path    => "${directory}/broker.conf",
    content => template('helix/p4broker_conf.erb'),
  }

  # manage the service. The actual service is `perforce-p4dctl`, but the p4dctl command
  # is used to manage the various service instances. it provides start/stop/restart/status
  # subcommands to manage the instance
  service { "${title}_p4broker_service":
    ensure  => $ensure,
    start   => "${p4dctl_path} start ${instance_name}",
    stop    => "${p4dctl_path} stop ${instance_name}",
    restart => "${p4dctl_path} restart ${instance_name}",
    status  => "${p4dctl_path} status ${instance_name}",
    require => File["${title}_broker.conf"],
  }
}
