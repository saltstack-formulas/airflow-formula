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

    {%- for name in a.service.airflow.enabled %}

        {%- if name == 'airflow-scheduler' and a.identity.airflow.role|lower == 'primary' %}
airflow-service-install-database:
  cmd.run:
    - name: {{ a.dir.airflow.virtualenv }}{{ a.div }}bin{{ a.div }}airflow {{ a.config.airflow.initcmd }}
    - runas: {{ a.identity.airflow.user }}
    - env:
        - PATH: '{{ a.dir.airflow.virtualenv }}{{ a.div }}bin:${PATH}'
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

    {%- endfor %}
