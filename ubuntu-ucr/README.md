Ubuntu UCR
===========

Ansible role to customize Ubuntu for University of Costa Rica.

Requirements
------------

Ansible >= 2.4.

Role Variables
--------------

- **apt_cache**: whether to preserve or not apt cache, defaults to **no**.
- **arch**: system architecture, defaults to **x86_64**.
- **wget_cache_path**: path where to create **wget** downloads folder, defaults to */tmp/wget_cache*.

Usage
-----

To execute:

    ansible-playbook customization.yml -i production -v --ask-become-pass --extra-vars "apt_cache=yes arch=amd64 wget_cache_path=$HOME/my-cache" --tags "execution"

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
