.. _readme:

airflow-formula
================

|img_travis| |img_sr| |img_pc|

.. |img_travis| image:: https://travis-ci.com/saltstack-formulas/airflow-formula.svg?branch=master
   :alt: Travis CI Build Status
   :scale: 100%
   :target: https://travis-ci.com/saltstack-formulas/airflow-formula
.. |img_sr| image:: https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg
   :alt: Semantic Release
   :scale: 100%
   :target: https://github.com/semantic-release/semantic-release
.. |img_pc| image:: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white
   :alt: pre-commit
   :scale: 100%
   :target: https://github.com/pre-commit/pre-commit

A SaltStack formula to manage Apache Airflow 1.0 and 2.0 (https://airflow.apache.org) on GNU/Linux. Airflow, RabbitMQ, Redis, and Postgres/MySQL is supported by saltstack-formulas community. 

Supported platforms are Ubuntu, CentOS7, and OpenSUSE15. Arch may work.

For installer see https://github.com/noelmcloughlin/airflow-component 

.. contents:: **Table of Contents**
   :depth: 1

General notes
-------------

See the full `SaltStack Formulas installation and usage instructions
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

If you are interested in writing or contributing to formulas, please pay attention to the `Writing Formula Section
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#writing-formulas>`_.

If you want to use this formula, please pay attention to the ``FORMULA`` file and/or ``git tag``,
which contains the currently released version. This formula is versioned according to `Semantic Versioning <http://semver.org/>`_.

See `Formula Versioning Section <https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#versioning>`_ for more details.

If you need (non-default) configuration, please pay attention to the ``pillar.example`` file and/or `Special notes`_ section.

Contributing to this repo
-------------------------

Commit messages
^^^^^^^^^^^^^^^

**Commit message formatting is significant!!**

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

pre-commit
^^^^^^^^^^

`pre-commit <https://pre-commit.com/>`_ is configured for this formula, which you may optionally use to ease the steps involved in submitting your changes.
First install  the ``pre-commit`` package manager using the appropriate `method <https://pre-commit.com/#installation>`_, then run ``bin/install-hooks`` and
now ``pre-commit`` will run automatically on each ``git commit``. ::

  $ bin/install-hooks
  pre-commit installed at .git/hooks/pre-commit
  pre-commit installed at .git/hooks/commit-msg

Special notes
-------------

ARCHLINUX
^^^^^^^^^
You need Salt python3 installed::

    pacman -Sy base-devel curl; curl -sSL https://aur.archlinux.org/cgit/aur.git/snapshot/salt-py3.tar.gz | tar xz; cd salt-py3; makepkg -Crsf; sudo -s;pacman -U salt-py3-*.pkg.tar*


LDAP and AD Login troubleshooting
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
If Airflow UI uses Microsoft Active Directory (AD) sometimes troubleshooting is required. Authentication configuration is read from /home/_username@example.com/airflow/webserver_config.py file. Know your site configuration - for LDAP use SOFTERRA LDAP BROWSER.  The following procedure is way to debug UI logins.

    $ sudo systemctl stop airflow-webserver
    $ export AIRFLOW__LOGGING__FAB_LOGGING_LEVEL=DEBUG
    $ export PATH="/home/_username@example.com/.local/bin:$PATH:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin"

Start Airflow UI service [repeatable]

    $ /home/_username@example.com/.local/bin/airflow webserver >bob 2>&1

Test login in Airflow UI. When finished, press CTRL+C in terminal and view the debug logfile relevant entries.

    $ vi bob

If futher testing is needed (tweaking configuration) just update webserver_config.py and follow [repeatable] procedure again until you are satisfied. Once complete, restart Airflow UI daemon:

    $ unset AIRFLOW__LOGGING__FAB_LOGGING_LEVEL
    $ sudo systemctl start airflow-webserver


Airflow Clusters
^^^^^^^^^^^^^^^^

Airflow / Messaging Clusters are configured via pillar data. The key pillar/attribute is `airflow:service:airflow:enabled` which defaults to all services `(airflow-celery-flower,airflow-scheduler,airflow-webserver,airflow-celery-worker)'`. In a scalable airflow cluster architecture, you can modify the list to distribute services. See the `pillar.example` file.  The following highstate (`top.sls`) is one possible example:

  base:
    '*':
        {%- if salt['pillar.get']('airflow:database:airflow:install', False) == true %}
      - postgres.dropped
      - postgres
        {%- endif %}
        {%- if salt['pillar.get']('airflow:config:airflow:content:core:executor', False) == 'CeleryExecutor' %}
      - rabbitmq.clean    # does not delete /var/lib/rabbitmq
      - rabbitmq
      - rabbitmq.config.cluster
        {%- endif %}
      - airflow

Available states
----------------

.. contents::
   :local:

``airflow``
^^^^^^^^^^^^

*Meta-state (This is a state that includes other states)*.

This installs the airflow package,
manages the airflow configuration file and then
starts the associated airflow service.

``airflow.package``
^^^^^^^^^^^^^^^^^^^^

This state will install the airflow pip package only.

``airflow.archive``
^^^^^^^^^^^^^^^^^^^^

This state will install the airflow archive only. ** Not implemented ** placeholder for potential windows support ***

``airflow.config``
^^^^^^^^^^^^^^^^^^^

This state will configure the airflow service and has a dependency on ``airflow.install``
via include list. It will also invoke ``airflow.config.flask`` for webserver and authentication.

``airflow.service``
^^^^^^^^^^^^^^^^^^^^

This state will start the airflow service and has a dependency on ``airflow.config``
via include list.

``airflow.clean``
^^^^^^^^^^^^^^^^^^

*Meta-state (This is a state that includes other states)*.

this state will undo everything performed in the ``airflow`` meta-state in reverse order, i.e.
stops the service,
removes the configuration file and
then uninstalls the package/archive. ** Not implemented ** placeholder for potential windows support ***

``airflow.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^

This state will stop the airflow service and disable it at boot time.

``airflow.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^

This state will remove the configuration of the airflow service and has a
dependency on ``airflow.service.clean`` via include list.

``airflow.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^

This state will remove the airflow package and has a depency on
``airflow.config.clean`` via include list.

``airflow.archive.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^

This state will remove the airflow archive and has a depency on
``airflow.config.clean`` via include list.


Available sub-states
--------------------

Various sub-states are available, including:


``airflow.config.flask``
^^^^^^^^^^^^^^^^^^^^^^^^

This state will configure the flask-appbuilder configuration file for airflow webservice and ui authentication.


Testing
-------

Linux testing is done with ``kitchen-salt``.

Requirements
^^^^^^^^^^^^

* Ruby
* Docker

.. code-block:: bash

   $ gem install bundler
   $ bundle install
   $ bin/kitchen test [platform]

Where ``[platform]`` is the platform name defined in ``kitchen.yml``,
e.g. ``debian-9-2019-2-py3``.

``bin/kitchen converge``
^^^^^^^^^^^^^^^^^^^^^^^^

Creates the docker instance and runs the ``airflow`` main state, ready for testing.

``bin/kitchen verify``
^^^^^^^^^^^^^^^^^^^^^^

Runs the ``inspec`` tests on the actual instance.

``bin/kitchen destroy``
^^^^^^^^^^^^^^^^^^^^^^^

Removes the docker instance.

``bin/kitchen test``
^^^^^^^^^^^^^^^^^^^^

Runs all of the stages above in one go: i.e. ``destroy`` + ``converge`` + ``verify`` + ``destroy``.

``bin/kitchen login``
^^^^^^^^^^^^^^^^^^^^^

Gives you SSH access to the instance for manual testing.
