# -*- coding: utf-8 -*-
# vim: ft=yaml
---
# This file includes rabbitmq and postgres pillar data examples

# postgres-rabbitmq

airflow:
  config:
    airflow:
      content:
        celery:
          broker_url: amqp://airflow:airflow@127.0.0.1:5672/airflow
  pkg:
    airflow:
      version: 2.1.0
      extras:
        # yamllint disable rule:line-length
        # https://airflow.apache.org/docs/apache-airflow/stable/installation.html#extra-packages
        # https://airflow.apache.org/docs/apache-airflow/stable/extra-packages-ref.html
        # yamllint enable rule:line-length
        # Services Extras
        - async
        - crypto
        - dask
        - datadog           # Datadog hooks and sensors
        - devel
        - devel_ci
        - jira              # Jira hooks and operators
        - sendgrid          # Send email using sendgrid
        - slack             # airflow.providers.slack.operators.slack.SlackAPIOperator
        ## Software Extras
        - celery            # CeleryExecutor
        - cncf.kubernetes   # Kubernetes Executor and operator
        - docker            # Docker hooks and operators
        - ldap              # LDAP authentication for users
        - microsoft.azure
        - microsoft.mssql   # Microsoft SQL server
        - rabbitmq          # RabbitMQ support as a Celery backend
        - redis             # Redis hooks and sensors
        - statsd            # Needed by StatsD metrics
        - virtualenv
        ## Standard protocol Extras
        - cgroups           # Needed To use CgroupTaskRunner
        - grpc              # Grpc hooks and operators
        - http              # http hooks and providers
        - kerberos          # Kerberos integration
        - sftp
        - sqlite
        - ssh               # SSH hooks and Operator
        - microsoft.winrm   # WinRM hooks and operators

postgres:
  # yamllint disable rule:syntax
  {%- if grains.os_family != 'Debian' %}
  use_upstream_repo: False
  {%- else %}
  use_upstream_repo: True
  {%- endif %}
  # yamllint enable rule:syntax
  version: 13
  postgresconf: |-
    listen_addresses = '*'  # or localhost,192.168.1.1'
  users:
    airflow:
      ensure: present
      password: airflow
      createdb: true
      inherit: true
      createroles: true
      replication: true
  databases:
    airflow:
      owner: airflow
  acls:
    # scope, db, user, [ cidr ] ..
    - ['local', 'airflow', 'airflow', 'md5']
    - ['local', 'all', 'all', 'peer']
    - ['host', 'all', 'all', '127.0.0.1/32', 'md5']
    - ['host', 'all', 'all', '191.168.1.1/32', 'md5']
    - ['host', 'all', 'all', '191.168.1.2/32', 'md5']
    - ['host', 'all', 'all', '::1/128', 'md5']
    - ['local', 'replication', 'all', 'peer']
    - ['host', 'replication', 'all', '127.0.0.1/32', 'md5']
    - ['host', 'replication', 'all', '::1/128', 'md5']

locale:
  present:
    - 'en_US.UTF-8 UTF-8'
  default:
    name: 'en_US.UTF-8'
    requires: 'en_US.UTF-8 UTF-8'

rabbitmq:
  erlang_cookie: shared-secret
  nodes:
    rabbit:  # default node name
      config:
        auth_backends.1: internal   # default
        listeners.tcp.1: 0.0.0.0:5672
        # https://www.rabbitmq.com/ldap.html
        # auth_backends.2: ldap
        # auth_ldap.servers.1: ldapserver.new
        # auth_ldap.servers.2: ldapserver.old
        # auth_ldap.user_dn_pattern: cn=${username},OU=myOrg,DC=example,DC=com
        # auth_ldap.log: false
        # auth_ldap.dn_lookup_attribute: sAMAccountName  # or userPrincipalName
        # auth_ldap.dn_lookup_base: OU=myOrg,DC=example,DC=com
      vhosts:
        - default_vhost
      queue:
        my-new-queue:
          ## note : dict format
          user: airflow_mq
          passwd: password
          durable: true
          auto_delete: false
          vhost: default_vhost
          arguments:
            - x-message-ttl: 8640000
            - x-expires: 8640000
            - x-dead-letter-exchange: my-new-exchange
      users:
        airflow_mq:
          password: password
          force: false
          tags:
            - administrator
            - management
          perms:
            default_vhost:
              - '.*'
              - '.*'
              - '.*'
      policy:
        my-new-rabbitmq-policy:
          - name: HA
          - pattern: '.*'
          - definition: '{"ha-mode": "all"}'
...
