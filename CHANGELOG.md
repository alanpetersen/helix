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
