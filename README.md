[![GitHub tag][gh-tag-img]][gh-link]

# Building a SCL-based LAMP stack with Puppet

## Purpose

Red Hat, CentOS, Fedora, and the like have access to Software Collections
which provide newer versions of popular software packages than what originally
shipped with the distro. The documentation on how to use
[puppetlabs/apache][puppetlabs/apache] with [SoftwareCollections.org][sc] or
Red Hat's Software Collections is more than a little lacking. This repo is my
attempt to fill tho gaps between the Puppet documentation and the reality of
doing such a setup.

## Goals

Once this repo reaches version 1.0.0 it should have, or be able to do, all
of the following:  
* Fully install, configure, and manage a SCL-based LAMP stack via Puppet
* Configure PHP-FPM for use with Apache via a file handler (introduced in
  Apache 2.4.10)
* Setup Apache and PHP to utilize a local MariaDB database
* Redirect all http requests to https in a way that plays nice with the
  [letsencrypt.org][le] client and the ["webroot"][webroot] method of
  verification.
* Configure [Passenger][passenger] for Ruby and Node.js
* Configure mod_remoteip to support parsing the X-Forwarded-For header


[gh-tag-img]: https://img.shields.io/github/tag/genebean/scl-lamp-stack-via-puppet.svg
[gh-link]: https://github.com/genebean/scl-lamp-stack-via-puppet
[le]: https://letsencrypt.org/
[passenger]: https://www.phusionpassenger.com/
[puppetlabs/apache]: https://forge.puppetlabs.com/puppetlabs/apache
[sc]: https://www.softwarecollections.org
[webroot]: https://letsencrypt.readthedocs.org/en/latest/using.html#webroot
