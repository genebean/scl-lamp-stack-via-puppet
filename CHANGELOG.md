[![GitHub tag][gh-tag-img]][gh-link]

## 2017-02-01 Release 0.4.0  
* MariaDB is now installed
* PHP-FPM is now using the event MPM instead of worker
* Basic testing of the Puppet manifest is now implemented
* Updated Vagrant box to Puppet 4
* Fixed a lot of puppet-lint's findings

## 2015-12-21 Release 0.3.0  
* The folder `website` in this repo is now the default document root
* The document root is owned by the user and group `vagrant` by default now
* Added all the PHP packages needed to support [phpMyAdmin][pma]
* Configured the installation of the PHP packages to restart the php-fpm service

## 2015-12-21 Release 0.2.1  
* modified goals on the readme to be a task list with check boxes

## 2015-12-21 Release 0.2.0  
* PHP-FPM works now. index.php shows `phpinfo()` on both ports 80 and 443.
* added two `apache::custom_config` blocks:
  * one to create the file handler for PHP-FPM
  * one to deal with the `ssl.conf` file that yum
    expects to reside in the conf.d directory. If this file doesn't exist yum
    will put it back the next time Apache is updated which can break the server
    until the next time Puppet purges unmanaged files.
* added the [Slashbunny-phpfpm][mod-phpfpm] Puppet module for installing and
  managing the config of PHP-FPM.
* moved the installation of `centos-release-scl-rh` into a step before applying
  `site.pp`.
* added symlinks to both root's and vagrant's home directories for easily
  accessing the the scl version of `/var/www` and `/etc/httpd`

## 2015-12-20 Release 0.1.0  
* Working base install of Apache. No index page is provided yet.


[gh-tag-img]: https://img.shields.io/github/tag/genebean/scl-lamp-stack-via-puppet.svg
[gh-link]: https://github.com/genebean/scl-lamp-stack-via-puppet
[mod-phpfpm]: https://forge.puppetlabs.com/Slashbunny/phpfpm
[pma]: https://www.phpmyadmin.net
