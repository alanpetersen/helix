## 2016-05-08 - Release 0.2.2
Updated redhat.pp class to check for existence of Perforce yum configuration 

## 2016-05-08 - Release 0.2.1
Updated debian.pp class to check for existence of Perforce apt configuration

## 2016-05-08 - Release 0.2.0
A few updates to address some issues with this module and the latest version of Perforce Helix.
- configured defined resources to have a p4dctl parameter
- in params.pp, defaulted p4dctl to /usr/sbin/p4dctl on RedHat systems and /usr/bin/p4dctl on Debian systems.
- added some additional checks in the defined resources for valid parameter values
- added beaker testing for Centos 7

## 2015-12-20 - Release 0.1.0
### Summary
This is the initial release. Mostly functional, some documentation still needed.

Right now, the release can:
* install and configure the Helix CLI package (p4)
* install and configure the Helix Server package (p4d)
* install and configure the Helix Broker package (p4broker)
* install and configure the Helix Proxy package (p4p)

For the p4d, p4broker, and p4proxy classes, there are associated
defined types to create instances of the services:
* helix::server_instance
* helix::broker_instance
* helix::proxy_instance
