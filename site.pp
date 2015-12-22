exec { 'create localhost cert':
  # lint:ignore:80chars
  command   => "/bin/openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -sha256 -subj '/CN=domain.com/O=My Company Name LTD./C=US' -keyout /etc/pki/tls/private/localhost.key -out /etc/pki/tls/certs/localhost.crt",
  # lint:endignore
  creates   => '/etc/pki/tls/certs/localhost.crt',
  logoutput => true,
  before    => Class['apache'],
}

user { 'webmaster':
  ensure => present,
  before => Class['apache'],
}

$scl_httpd = '/opt/rh/httpd24/root'

class { 'apache':
  apache_name           => 'httpd24-httpd',
  apache_version        => '2.4',
  conf_dir              => "${scl_httpd}/etc/httpd/conf",
  confd_dir             => "${scl_httpd}/etc/httpd/conf.d",
  default_mods          => false,
  default_ssl_vhost     => false,
  default_vhost         => false,
  dev_packages          => 'httpd24-httpd-devel',
  docroot               => "${scl_httpd}/var/www/html",
  httpd_dir             => "${scl_httpd}/etc/httpd",
  logroot               => '/var/log/httpd24',
  mod_dir               => "${scl_httpd}/etc/httpd/conf.modules.d",
  mpm_module            => 'worker',
  pidfile               => '/opt/rh/httpd24/root/var/run/httpd/httpd.pid',
  ports_file            => "${scl_httpd}/etc/httpd/conf/ports.conf",
  purge_configs         => true,
  serveradmin           => 'root@localhost',
  servername            => 'demobox.example.com',
  server_root           => "${scl_httpd}/etc/httpd",
  service_name          => 'httpd24-httpd',
  trace_enable          => false,
  vhost_dir             => "${scl_httpd}/etc/httpd/conf.d",
  vhost_include_pattern => '*.conf',
}

apache::custom_config { 'php-fpm':
  confdir        => "${scl_httpd}/etc/httpd/conf.modules.d",
  priority       => false,
  source         => '/vagrant/php-fpm.conf',
  verify_command => '/bin/scl enable httpd24 "apachectl -t"',
  notify         => Service['httpd'],
}

if ($::apache::mod_dir != $::apache::config_dir) {
  apache::custom_config { 'mod_ssl_fix':
    name           => 'ssl',
    confdir        => "${scl_httpd}/etc/httpd/conf.d",
    priority       => false,
    content        => "# This file has moved to ${::apache::mod_dir}",
    verify_command => '/bin/scl enable httpd24 "apachectl -t"',
    require        => Class['apache::mod::ssl'],
    notify         => Service['httpd'],
  }
}

apache::vhost { 'main-site-nonssl':
  ip            => '*',
  ip_based      => true,
  port          => '80',
  docroot       => "${scl_httpd}/var/www/main-site",
  docroot_owner => 'webmaster',
  docroot_group => 'webmaster',
}

apache::vhost { 'main-site-ssl':
  ip            => '*',
  ip_based      => true,
  port          => '443',
  docroot       => "${scl_httpd}/var/www/main-site",
  docroot_owner => 'webmaster',
  docroot_group => 'webmaster',
  ssl           => true,
  ssl_cert      => '/etc/pki/tls/certs/localhost.crt',
  ssl_key       => '/etc/pki/tls/private/localhost.key',
}

class { 'apache::dev': }
class { 'apache::mod::dir': }
class { 'apache::mod::proxy': }
class { 'apache::mod::setenvif': }
class { 'apache::mod::ssl':
  package_name => 'httpd24-mod_ssl',
}

class {'phpfpm':
  package_name    => 'rh-php56-php-fpm',
  service_name    => 'rh-php56-php-fpm',
  config_dir      => '/etc/opt/rh/rh-php56',
  pool_dir        => '/etc/opt/rh/rh-php56/php-fpm.d',
  pid_file        => '/var/opt/rh/rh-php56/run/php-fpm/php-fpm.pid',
  restart_command => 'systemctl reload rh-php56-php-fpm',
}

file { '/opt/rh/httpd24/root/var/www/main-site/index.php':
  ensure  => file,
  mode    => '0644',
  content => '<?php phpinfo(); ?>',
  require => Apache::Vhost['main-site-ssl'],
}

file { '/var/log/php-fpm':
  ensure => directory,
  mode   => '0700',
  before => Class['phpfpm'],
}
