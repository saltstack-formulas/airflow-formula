# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as a with context %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- set sls_config_flask = tplroot ~ '.config.flask' %}
{%- set sls_config_environ = tplroot ~ '.config.environ' %}
{%- set sls_service_install = tplroot ~ '.service.install' %}

include:
  - {{ sls_config_file }}
  - {{ sls_config_flask }}
  - {{ sls_config_environ }}
  - {{ sls_service_install }}

    {%- for name in a.service.airflow.names %}
        {%- if name in a.service.airflow.enabled %}

            {%- if name == 'airflow-scheduler' and a.database.airflow.initdb == true %}
airflow-service-install-database:
  cmd.run:
    - name: {{ a.dir.airflow.virtualenv }}/bin/airflow {{ a.config.airflow.initdbcmd }}
    - runas: {{ a.identity.airflow.user }}
    - env:
        - PATH: '{{ a.dir.airflow.virtualenv }}/bin:${PATH}'
        - PGPASSWORD: '{{ a.database.airflow.pass }}'
            {%- endif %}

airflow-service-running-{{ name }}:
  service.running:
    - name: {{ name }}
    - enable: True
        {%- if grains.kernel|lower == 'linux' %}
    - onlyif: systemctl list-unit-files | grep {{ name }} >/dev/null 2>&1
        {%- endif %}
    - onchanges:
      - sls: {{ sls_config_file }}
      - sls: {{ sls_config_flask }}
      - sls: {{ sls_config_environ }}
      - sls: {{ sls_service_install }}
    - watch:
      - sls: {{ sls_config_file }}
    - retry: {{ a.retry_option|json }}
  cmd.run:
    - name: sleep 1 && systemctl status {{ name }}

        {%- else %}

airflow-service-running-{{ name }}-disable:
  service.dead:
    - name: {{ name }}
    - enable: False

        {%- endif %}
    {%- endfor %}
