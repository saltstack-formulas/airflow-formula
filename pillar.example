# -*- coding: utf-8 -*-
# vim: ft=yaml
---
postgres:
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
    - ['local', 'airflow', 'airflow', 'md5']
    - ['local', 'all', 'all', 'peer']
    - ['host', 'all', 'all', '127.0.0.1/32', 'md5']
    - ['host', 'all', 'all', '::1/128', 'md5']
    - ['local', 'replication', 'all', 'peer']
    - ['host', 'replication', 'all', '127.0.0.1/32', 'md5']
    - ['host', 'replication', 'all', '::1/128', 'md5']

airflow:
  identity:
    airflow:
      user: airflow
      group: airflow
      skip_user_state: false   # local user
  database:
    airflow:
      user: airflow
      pass: airflow
      email: airflow@localhost
  config:
    airflow:
      flask:
        auth_type: AUTH_DB # AUTH_LDAP, etc
        auth_user_registration: False
        auth_user_registration_role: Admin
        #### Active Directory Example ####
        auth_ldap_server: ldap://ldapserver.new
        auth_ldap_search_filter: (memberOf=CN=myGrpRole,OU=myOrg,DC=example,DC=com)
        # match multiple groups: (memberOf=(CN=myGrp*),OU=myOrg,DC=example,DC=com)
        auth_ldap_append_domain: example.com

      content:
        api: {}
        celery_kubernetes_executor: {}
        celery:
          # https://docs.celeryproject.org/en/v5.0.2/getting-started/brokers
          broker_url: redis://127.0.0.1:6379/0
          result_backend: db+postgresql://airflow:airflow@127.0.0.1/airflow
        cli: {}
        core:
          authentication: True  # gone in v2
          dags_folder: /home/airflow/dags
          plugins_folder: /home/airflow/plugins
          executor: CeleryExecutor
          default_timezone: utc
          load_examples: True
          # https://stackoverflow.com/questions/45455342
          sql_alchemy_conn: postgresql+psycopg2://airflow:airflow@127.0.0.1/airflow
          security: ''
        dask: {}
        elasticsearch: {}
        kerberos: {}
        kubernetes: {}
        ldap: {}   # gone in v2
        logging: {}
        metrics: {}
        secrets: {}
        sentry: {}
        smart_sensor: {}
        smtp: {}
        webserver:
          secret_key: {{ range(1,20000000000) | random }}
      state_colors:
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
  pkg:
    airflow:
      version: 2.0.0  # 1.10.14
      use_upstream: pip
      # "extras" are installed via 'pip install apache-airflow[extras,]==version'
      # "providers" are installed via 'pip install [providers,]'
      # If you want airflow.providers instead, set empty dict (extras: {}) here
      # and run that state by itself, on-demand. See providers dict.
      extras:
        # https://airflow.apache.org/docs/apache-airflow/stable/installation.html#extra-packages
        # NOT VERIFIED OR "I HAD ISSUES WITH THESE!"
        # all            # All Airflow features known to man    # NOT VERIFIED
        # all_dbs        # All databases integrations    # NOT VERIFIED
        # devel_all      # All dev tools requirements    # NOT VERIFIED
        # devel_hadoop   # Airflow + dependencies on the Hadoop stack    # NOT VERIFIED
        # doc            # Packages needed to build docs    # NOT VERIFIED
        # cloudant       # cloudant
        # salesforce     # Salesforce hook
        # snowflake      # Snowflake hooks and operators
        # oracle         # Oracle hooks and operators
        # jdbc           # JDBC hooks and operators
        
        # THESE WORKED
        - devel          # Minimum dev tools requirements
        - devel_ci       # Development requirements used in CI
        - devel_azure    # Azure development requirements
        - password       # Password authentication for users
        - apache.atlas      # Apache Atlas to use Data Lineage feature
        - apache.cassandra  # Cassandra related operators & hook
        - apache.druid      # Druid related operators & hooks
        - apache.hdfs       # HDFS hooks and operators
        - apache.hive       # All Hive related operators
        - apache.pinot         # Pinot DB hook
        - webhdfs           # HDFS hooks and operators
        # apache.presto     # All Presto related operators & hooks   (not in airflow 2.0.0)
        - amazon               # aws
        # azure_container_instances   # not in airflow 2.0.0
        # azure_blob_storage   # not in airflow 2.0.0
        # azure_cosmos         # not in airflow 2.0.0
        # azure_data_lake      # not in airflow 2.0.0
        # azure_secrets        # not in airflow 2.0.0
        - microsoft.azure      # azure
        - databricks           # Databricks hooks and operators
        - datadog              # Datadog hooks and sensors
        - google               # Google Cloud
        - google_auth          # Google auth backend
        - github_enterprise    # GitHub Enterprise auth backend
        - hashicorp            # Hashicorp Services (Vault)
        - http                 # http hooks and providers
        - jira                 # Jira hooks and operators
        - qubole               # Enable QDS (Qubole Data Service) support
        - salesforce           # Salesforce hook
        - sendgrid             # Send email using sendgrid
        - segment              # Segment hooks and sensors
        - sentry
        - slack                # airflow.providers.slack.operators.slack.SlackAPIOperator
        - vertica              # Vertica hook support as an Airflow backend
        ## Software
        - async                # Async worker classes for Gunicorn
        - celery               # CeleryExecutor
        - dask                 # DaskExecutor
        - docker               # Docker hooks and operators
        - elasticsearch        # Elasticsearch hooks and Log Handler
        - cncf.kubernetes      # Kubernetes Executor and operator
        - mongo                # Mongo hooks and operators
        - mysql                # MySQL operators and hook, support as Airflow backend (mysql 5.6.4+)
        - postgres             # PostgreSQL operators and hook, support as an Airflow backend
        - rabbitmq             # RabbitMQ support as a Celery backend
        - redis                # Redis hooks and sensors
        - samba                # airflow.providers.apache.hive.transfers.hive_to_samba.HiveToSambaOperator
        - statsd               # Needed by StatsD metrics
        - virtualenv
        - cgroups              # Needed To use CgroupTaskRunner
        - crypto               # Cryptography libraries
        - grpc                 # Grpc hooks and operators
        - kerberos             # Kerberos integration
        - ldap                 # LDAP authentication for users
        - imap                 # IMAP hooks and sensors
        - papermill            # Papermill hooks and operators
        - ssh                  # SSH hooks and Operator
        - pagerduty            # PagerDuty ..
        - microsoft.winrm      # WinRM hooks and operators
      providers:
        - apache-airflow-providers-apache-cassandra
        - apache-airflow-providers-apache-druid
        - apache-airflow-providers-apache-hdfs
        - apache-airflow-providers-apache-hive
        - apache-airflow-providers-apache-kylin
        - apache-airflow-providers-apache-livy
        - apache-airflow-providers-apache-pig
        - apache-airflow-providers-apache-pinot
        - apache-airflow-providers-apache-spark
        - apache-airflow-providers-apache-sqoop
        - apache-airflow-providers-celery
        - apache-airflow-providers-cloudant
        - apache-airflow-providers-cncf-kubernetes
        - apache-airflow-providers-databricks
        - apache-airflow-providers-datadog
        - apache-airflow-providers-dingding
        - apache-airflow-providers-discord
        - apache-airflow-providers-docker
        - apache-airflow-providers-elasticsearch
        - apache-airflow-providers-exasol
        - apache-airflow-providers-facebook
        - apache-airflow-providers-ftp
        - apache-airflow-providers-google
        - apache-airflow-providers-grpc
        - apache-airflow-providers-hashicorp
        - apache-airflow-providers-imap
        - apache-airflow-providers-jdbc
        - apache-airflow-providers-jenkins
        - apache-airflow-providers-jira
        - apache-airflow-providers-microsoft-azure
        - apache-airflow-providers-microsoft-mssql
        - apache-airflow-providers-microsoft-winrm
        - apache-airflow-providers-mongo
        - apache-airflow-providers-mysql
        - apache-airflow-providers-odbc
        - apache-airflow-providers-openfaas
        - apache-airflow-providers-opsgenie
        - apache-airflow-providers-oracle
        - apache-airflow-providers-pagerduty
        - apache-airflow-providers-papermill
        - apache-airflow-providers-plexus
        - apache-airflow-providers-postgres
        - apache-airflow-providers-presto
        - apache-airflow-providers-qubole
        - apache-airflow-providers-redis
        - apache-airflow-providers-salesforce
        - apache-airflow-providers-samba
        - apache-airflow-providers-segment
        - apache-airflow-providers-sendgrid
        - apache-airflow-providers-sftp
        - apache-airflow-providers-singularity
        - apache-airflow-providers-slack
        - apache-airflow-providers-snowflake
        - apache-airflow-providers-sqlite
        - apache-airflow-providers-ssh
        - apache-airflow-providers-telegram
        - apache-airflow-providers-vertica
        - apache-airflow-providers-yandex
        - apache-airflow-providers-zendesk
        - apache-airflow-providers-amazon

  linux:
    altpriority: 0   # zero disables alternatives

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
