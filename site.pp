exec { 'create localhost cert':
  # lint:ignore:80chars
  command   => "/bin/openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -sha256 -subj '/CN=domain.com/O=My Company Name LTD./C=US' -keyout /etc/pki/tls/private/localhost.key -out /etc/pki/tls/certs/localhost.crt",
  # lint:endignore
  creates   => '/etc/pki/tls/certs/localhost.crt',
  logoutput => true,
  before    => Class['apache'],
}

package { 'centos-release-scl-rh':
  ensure => installed,
}

$packages = [
  'httpd24',
  'rh-php56',
  'scl-utils',
]

package { $packages:
  ensure  => installed,
  before  => Class['apache'],
  require => Package['centos-release-scl-rh'],
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

class { 'apache::dev': }

class { 'apache::mod::dir': }
class { 'apache::mod::ssl':
  package_name => 'httpd24-mod_ssl',
}

apache::vhost { 'main-site-nonssl':
  ip            => '*',
  ip_based      => true,
  port          => '80',
  docroot       => "${scl_httpd}/var/www/main-site",
#  docroot_owner => 'webmaster',
#  docroot_group => 'webmaster',
}

apache::vhost { 'main-site-ssl':
  ip            => '*',
  ip_based      => true,
  port          => '443',
  docroot       => "${scl_httpd}/var/www/main-site",
#  docroot_owner => 'webmaster',
#  docroot_group => 'webmaster',
  ssl           => true,
  ssl_cert      => '/etc/pki/tls/certs/localhost.crt',
  ssl_key       => '/etc/pki/tls/private/localhost.key',
}
