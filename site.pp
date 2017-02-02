$apache_user   = 'vagrant'
$website_owner = 'vagrant'
$website_group = 'vagrant'
$log_formats      = {
  'combined' => '%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"',
}

exec { 'create localhost cert':
  # lint:ignore:80chars lint:ignore:140chars
  command   => "/bin/openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -sha256 -subj '/CN=domain.com/O=My Company Name LTD./C=US' -keyout /etc/pki/tls/private/localhost.key -out /etc/pki/tls/certs/localhost.crt",
  # lint:endignore
  creates   => '/etc/pki/tls/certs/localhost.crt',
  logoutput => true,
  before    => Class['apache'],
}

if ($apache_user != $website_owner) {
  user { $website_owner:
    ensure => present,
    before => Class['apache'],
  }
}

$scl_httpd = '/opt/rh/httpd24/root'

class { '::apache':
  apache_name           => 'httpd24-httpd',
  apache_version        => '2.4',
  conf_dir              => "${scl_httpd}/etc/httpd/conf",
  confd_dir             => "${scl_httpd}/etc/httpd/conf.d",
  default_charset       => 'UTF-8',
  default_mods          => false,
  default_ssl_vhost     => false,
  default_vhost         => false,
  dev_packages          => 'httpd24-httpd-devel',
  docroot               => "${scl_httpd}/var/www/html",
  httpd_dir             => "${scl_httpd}/etc/httpd",
  log_formats           => $log_formats,
  logroot               => '/var/log/httpd24',
  mod_dir               => "${scl_httpd}/etc/httpd/conf.modules.d",
  mpm_module            => 'event',
  pidfile               => '/opt/rh/httpd24/root/var/run/httpd/httpd.pid',
  ports_file            => "${scl_httpd}/etc/httpd/conf/ports.conf",
  purge_configs         => true,
  serveradmin           => 'root@localhost',
  servername            => 'demobox.example.com',
  server_root           => "${scl_httpd}/etc/httpd",
  service_name          => 'httpd24-httpd',
  ssl_file              => "${scl_httpd}/etc/httpd/conf.modules.d/ssl.conf",
  trace_enable          => false,
  user                  => $apache_user,
  vhost_dir             => "${scl_httpd}/etc/httpd/conf.d",
  vhost_include_pattern => '*.conf',
}

apache::custom_config { 'php-fpm':
  confdir        => "${scl_httpd}/etc/httpd/conf.modules.d",
  priority       => false,
  source         => '/vagrant/php-fpm.conf',
  verify_command => '/bin/scl enable httpd24 "apachectl -t"',
  notify         => Service['httpd'],
  require        => Apache::Vhost['main-site-ssl'],
}

apache::vhost { 'main-site-nonssl':
  ip            => '*',
  ip_based      => true,
  port          => '80',
  docroot       => "${scl_httpd}/var/www/main-site",
  docroot_owner => $website_owner,
  docroot_group => $website_owner,
}

apache::vhost { 'main-site-ssl':
  ip            => '*',
  ip_based      => true,
  port          => '443',
  docroot       => "${scl_httpd}/var/www/main-site",
  docroot_owner => $website_owner,
  docroot_group => $website_owner,
  ssl           => true,
  ssl_cert      => '/etc/pki/tls/certs/localhost.crt',
  ssl_key       => '/etc/pki/tls/private/localhost.key',
}

class { '::apache::dev': }
::apache::mod { 'access_compat': }
class { '::apache::mod::alias': }
class { '::apache::mod::auth_basic': }
class { '::apache::mod::authn_core': }
class { '::apache::mod::authn_file': }
class { '::apache::mod::authz_user': }
::apache::mod { 'authz_groupfile': }
class { '::apache::mod::dir': }
class { '::apache::mod::info':
  allow_from => ['127.0.0.1','::1'],
  info_path  => '/server-info',
}
class { '::apache::mod::proxy': }
class { '::apache::mod::proxy_balancer': }
class { '::apache::mod::proxy_fcgi': }
class { '::apache::mod::remoteip':
  proxy_ips => [ '127.0.0.1' ],
}
class { '::apache::mod::rewrite': }
class { '::apache::mod::setenvif': }
class { '::apache::mod::ssl':
  package_name => 'httpd24-mod_ssl',
}
class { '::apache::mod::status':
  allow_from  => ['127.0.0.1','::1'],
  status_path => '/server-status',
}

file { '/var/log/php-fpm':
  ensure => directory,
  mode   => '0700',
  before => Class['phpfpm'],
}

$phpfpm_sock_dirs = [
  '/opt/rh/rh-php56/root/var/run',
  '/opt/rh/rh-php56/root/var/run/php-fpm',
]

file { $phpfpm_sock_dirs:
  ensure  => directory,
  owner   => $website_owner,
  group   => $website_group,
  mode    => '0755',
  require => Package['rh-php56-php-fpm'],
  before  => Service['rh-php56-php-fpm'],
}

file { '/var/opt/rh/rh-php56/lib/php/session':
  ensure  => directory,
  owner   => $website_owner,
  group   => $website_group,
  require => Class['phpfpm'],
}

class {'::phpfpm':
  package_name    => 'rh-php56-php-fpm',
  service_name    => 'rh-php56-php-fpm',
  config_dir      => '/etc/opt/rh/rh-php56',
  error_log       => '/var/opt/rh/rh-php56/log/php-fpm/error.log',
  pool_dir        => '/etc/opt/rh/rh-php56/php-fpm.d',
  poold_purge     => true,
  pid_file        => '/var/opt/rh/rh-php56/run/php-fpm/php-fpm.pid',
  restart_command => 'systemctl reload rh-php56-php-fpm',
}

phpfpm::pool { 'www':
  user                   => $website_owner,
  group                  => $website_group,
  # lint:ignore:80chars
  listen                 => '/opt/rh/rh-php56/root/var/run/php-fpm/php-fpm.sock',
  # lint:endignore
  listen_allowed_clients => '127.0.0.1',
  listen_owner           => $website_owner,
  listen_group           => $website_group,
  listen_mode            => '0660',
  pm_max_children        => 250,
  pm_start_servers       => 50,
  pm_min_spare_servers   => 25,
  pm_max_spare_servers   => 50,
  pool_dir               => '/etc/opt/rh/rh-php56/php-fpm.d',
  slowlog                => '/var/opt/rh/rh-php56/log/php-fpm/www-slow.log',
  service_name           => 'rh-php56-php-fpm',
  php_admin_value        => {
    'error_log' => '/var/opt/rh/rh-php56/log/php-fpm/www-error.log',
  },
  php_admin_flag         => {
    'log_errors' => 'on',
  },
  php_value              => {
    'session.save_handler' => 'files',
    'session.save_path'    => '/var/opt/rh/rh-php56/lib/php/session',
    'soap.wsdl_cache_dir'  => '/var/opt/rh/rh-php56/lib/php/wsdlcache',
  },
}

file { "${scl_httpd}/var/www/main-site":
  ensure  => link,
  target  => '/vagrant/website',
  force   => true,
  require => Class['apache'],
}

file { "${scl_httpd}/var/www/main-site/index.php":
  ensure  => file,
  mode    => '0644',
  content => '<?php phpinfo(); ?>',
  require => File["${scl_httpd}/var/www/main-site"],
}

$php_packages = [
  'rh-php56-php-bcmath',
  'rh-php56-php-cli',
  'rh-php56-php-common',
  'rh-php56-php-devel',
  'rh-php56-php-gd',
  'rh-php56-php-mbstring',
  'rh-php56-php-mysqlnd',
  'rh-php56-php-pdo',
  'rh-php56-php-pear',
  'rh-php56-php-pecl-jsonc',
  'rh-php56-php-pecl-jsonc-devel',
  'rh-php56-php-process',
  'rh-php56-php-xml',
]

package { $php_packages:
  ensure => installed,
  notify => Service['rh-php56-php-fpm'],
}

package { 'mariadb55-mariadb-server':
  ensure => installed,
  notify => Service['mariadb55-mariadb.service'],
}

service { 'mariadb55-mariadb.service':
  ensure  => running,
  enable  => true,
  require => Package['mariadb55-mariadb-server'],
}
