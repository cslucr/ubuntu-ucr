Ubuntu UCR
===========

Ansible role to customize Ubuntu for Universidad of Costa Rica.

Requirements
------------

Ansible >= 2.4.

Role Variables
--------------

- **apt_cache**: whether to preserve or not apt cache, defaults to **no**.
- **arch**: system architecture, defaults to **amd64**.
- **no_force**: does not ask for anything, defaults to **false**.
- **wget_cache_path**: path where to create wget downloads folder, defaults to */tmp/wget_cache*.

Dependencies
------------

No dependencies.

Example Playbook
----------------

To include:

    - hosts: servers
      roles:
         - { role: ubuntu-ucr }

To execute:

    ansible-playbook -v customization.yml --extra-vars "apt_cache=true wget_cache_path=$HOME/my-cache force=true arch=amd64" --ask-become-pass

License
-------

GPL 3.

Author Information
------------------

Comunidad de Software Libre de la Universidad de Costa Rica (CSLUCR).
