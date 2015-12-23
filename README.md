# helix

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with helix](#setup)
    * [What helix affects](#what-helix-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with helix](#beginning-with-helix)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

## Overview

This module is used to manage various Perforce Helix components that are available
as Linux packages.

## Module Description

Helix is a version management system that incorporates a combination of services. 

[Introduction to Perforce Helix](http://www.perforce.com/perforce/r15.2/manuals/intro)

If your module has a range of functionality (installation, configuration,
management, etc.) this is the time to mention it.

* [Helix Administration Guide](https://www.perforce.com/perforce/doc.current/manuals/p4sag/index.html)
* [Helix Multi-Site Deployment Guide](https://www.perforce.com/perforce/doc.current/manuals/p4dist/index.html)


## Setup

### What helix affects

* A list of files, packages, services, or operations that the module will alter,
  impact, or execute on the system it's installed on.
* This is a great place to stick any warnings.
* Can be in list or paragraph form.

### Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled,
etc.), mention it here.

### Beginning with helix

The very basic steps needed for a user to get the module up and running.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you may wish to include an additional section here: Upgrading
(For an example, see http://forge.puppetlabs.com/puppetlabs/firewall).

## Usage

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

## Reference

Here, list the classes, types, providers, facts, etc contained in your module.
This section should include all of the under-the-hood workings of your module so
people know what the module is touching on their system but don't need to mess
with things. (We are working on automating this section!)

## Limitations

This module is only supported on Linux (RedHat and Ubuntu), as those are the
only packages available from the Perforce Helix distribution.
