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
          broker_url: redis://127.0.0.1:6379/0
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
        - snowflake
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

rabbitmq:
  cluster:
    rabbit@locahost:
      user: rabbit       # user is confusing keyname; should be 'node: rabbit'
      host: 127.0.0.1    # host of (primary rabbitmq cluster) node to join to
      ram_node: None
      runas: rabbitmq
      erlang_cookie:
        name: /var/lib/rabbitmq/.erlang.cookie
        value: shared-value-for-all-cluster-members
  vhost:
    - airflow
  user:
    airflow:
      - password: 'airflow'
      - force: true
      - tags:
          - management
          - administrator
      - perms:
          - 'airflow':
              - '.*'
              - '.*'
              - '.*'
      - runas: rabbitmq
  queue:
    airflow:
      # note dict format
      user: airflow
      passwd: airflow
      durable: true
      auto_delete: false
      vhost: airflow
      arguments:
        - 'x-message-ttl': 8640000
        - 'x-expires': 8640000
        - 'x-dead-letter-exchange': 'airflow'
  binding:
    airflow:
      - destination_type: queue
      - destination: airflow
      - routing_key: airflow_routing_key
      - user: airflow
      - passwd: password
      - vhost: airflow
      - arguments:
          - 'x-message-ttl': 8640000
  exchange:
    airflow:
      - user: airflow
      - passwd: airflow
      - type: fanout
      - durable: true
      - internal: false
      - auto_delete: false
      - vhost: airflow
      - arguments:
          - 'alternate-**exchange': 'amq.fanout'
          - 'test-header': 'testing'
  policy: {}
  upstream: {}
...
