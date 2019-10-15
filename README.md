IntelMQ
=========

IntelMQ is an IT security solution capable of collecting and processing security feeds (such as log files) using a message queuing protocol.

This roles installs the IntelMQ along with the user interface for its configuration and management.

Requirements
------------

None
=======
Apache web server with PHP 7.2+ must be running on the host.

Role Variables
--------------

Variables set in the defaults/main.yml:

    intelmq:
      install:
        source: package   # enum, repo|package
      configuration_file: []    # paths to configuration files

    intelmq_manager:
      install:
        source: package
      domain: "intelmq.local"
      authorization:
        file:
          path: "/etc/intelmq-manager.htusers"
        user:
          name: admin
          password: admin
      configuration:
        file:
          path: "{{ intelmq['bot_config_path'] }}/manager/"

Additional variables that can be set:

    intelmq_manager:
      configuration_file: "/path/to/my/config"


Dependencies
------------

None

Example Playbook
----------------

    - hosts: servers
      roles:
         - { role: intelmq }

License
-------

GPLv3

Author Information
------------------

Tibor Csóka
