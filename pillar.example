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
  security:
    airflow:
      user: airflow
      pass: airflow
      email: airflow@localhost
  config:
    airflow:
      content:
        core:
          authentication: True
          executor: CeleryExecutor
          load_examples: True
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
        # apache-airflow-providers-microsoft-winrm   # v1


  dir:
    airflow:
      config: /home/airflow/airflow
  linux:
    altpriority: 0   # zero disables alternatives

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
