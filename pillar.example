# -*- coding: utf-8 -*-
# vim: ft=yaml
---
# This file includes postgres pillar data example

airflow:
  identity:
    airflow:
      user: airflow
      group: airflow
      # skip_user_state: true  # if airflow user already exists
  database:
    airflow:
      install: true        # see docs/README
      user: airflow
      pass: airflow
      email: airflow@127.0.0.1
  config:
    airflow:
      pip_cmd: pip3
      flask:
        # yamllint disable-line rule:line-length
        # https://flask-appbuilder.readthedocs.io/en/latest/security.html#authentication-ldap
        auth_type: AUTH_DB  # AUTH_LDAP
        auth_ldap_server: ldap://ldapserver.new  # include protocol (ldap or ldaps)
        auth_ldap_append_domain: example.com
        auth_ldap_uid_field: 'sAMAccountName'  # or 'userPrincipalName'

        auth_ldap_search: OU=myOrg,DC=example,DC=com
        # yamllint disable rule:line-length
        ## https://confluence.atlassian.com/kb/how-to-write-ldap-search-filters-792496933.html
        auth_ldap_search_filter: (&(objectCategory=Person)(sAMAccountName=*)(|memberOf=CN=myGrpRole,OU=myOrg,DC=example,DC=com)
        # yamllint enable rule:line-length

        # auth_ldap_search: 'OU=ouEngineers_myteam,dc=example,dc=com'
        auth_user_registration_role: "Admin"  # in addition to any AUTH_ROLES_MAPPING
        auth_user_registration: true   # allow users who are not already in the FAB DB
        auth_roles_mapping:
          cn=fab_users,ou=groups,dc=example,dc=com: User
          cn=fab_admins,ou=groups,dc=example,dc=com: Admin
        auth_roles_sync_at_login: true
        webserver:
          web_server_host: 0.0.0.0
          web_server_port: 18080

      content:
        api: {}
        celery_kubernetes_executor: {}
        celery:
          # https://docs.celeryproject.org/en/v5.0.2/getting-started/brokers
          # yamllint disable-line rule:line-length
          broker_url: amqp://airflow:airflow@127.0.0.1:5672/airflow  # redis://127.0.0.1:6379/0
          ## result backend is usually primary airflow host
          result_backend: db+postgresql://airflow:airflow@127.0.0.1/airflow
        cli: {}
        core:
          dags_folder: /home/airflow/dags
          plugins_folder: /home/airflow/plugins
          executor: CeleryExecutor
          default_timezone: utc
          load_examples: true
          # https://stackoverflow.com/questions/45455342
          # this is your database host
          sql_alchemy_conn: postgresql+psycopg2://airflow:airflow@127.0.0.1/airflow
          security: ''
        operators:
          default_queue: airflow
        webserver:
          # yamllint disable-line rule:braces
          secret_key: {{ range(1, 2000)|random }}
      state_colors:
        # yamllint disable-line rule:line-length
        # https://airflow.apache.org/docs/apache-airflow/stable/howto/customize-state-colors-ui.html
        queued: 'darkgray'
        running: '#01FF70'
        success: '#2ECC40'
        failed: 'firebrick'
        up_for_retry: 'yellow'
        up_for_reschedule: 'turquoise'
        upstream_failed: 'orange'
        skipped: 'darkorchid'
        scheduled: 'tan'
  service:
    airflow:
      enabled:
        - airflow-celery-flower
        - airflow-scheduler
        - airflow-webserver
        - airflow-celery-worker
      # https://airflow.apache.org/docs/apache-airflow/stable/executor/celery.html
      queues: []
      # http://airflow.apache.org/docs/apache-airflow/stable/security/workload.html#impersonation
      impersonation: []
      # airflow-celery-worker
  pkg:
    airflow:
      version: 2.1.0
      # https://github.com/pypa/pip/issues/9187
      # https://pip.pypa.io/en/latest/user_guide/#dependency-resolution-backtracking
      # no_pips_deps: true  # for salt.virtualenv.managed.no_deps flag
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
  linux:
    altpriority: 0   # zero disables alternatives

postgres:
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
...
