Ubuntu UCR
===========

Ansible role to customize Ubuntu for University of Costa Rica.

Requirements
------------

Ansible >= 2.4.

Role Variables
--------------

- **apt_cache**: whether to preserve or not apt cache, defaults to **no**.
- **wget_cache_path**: path where to create **wget** downloads folder, defaults to */tmp/wget_cache*.

Role Facts
----------

- **ansible_architecture**: system architecture: **x86** or **x86_64**.
- **mate_xsession**: **True** when [mate-desktop](https://mate-desktop.org) is installed, **False** otherwise.
- **user_on_host**: non-root user running the play.

Usage
-----

To execute:

      ansible-galaxy install cslucr.ubuntu-ucr

To include:

    - hosts: servers
      roles:
         - { role: ubuntu-ucr }

License
-------

GPL 3.

Author Information
------------------

Comunidad de Software Libre de la Universidad de Costa Rica (CSLUCR).
