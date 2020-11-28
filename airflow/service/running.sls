# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- set sls_config_environ = tplroot ~ '.config.environ' %}
{%- set sls_service_install = tplroot ~ '.service.install' %}

include:
  - {{ sls_config_file }}
  - {{ sls_config_environ }}
  - {{ sls_service_install }}

    {%- for name in d.service.airflow.enabled %}

airflow-service-running-{{ name }}:
  service.running:
    - name: {{ name }}
    - enable: True
        {%- if grains.kernel|lower == 'linux' %}
    - onlyif: systemctl list-unit-files | grep {{ name }} >/dev/null 2>&1
        {%- endif %}
    - require:
      - sls: {{ sls_config_file }}
      - sls: {{ sls_config_environ }}
      - sls: {{ sls_service_install }}
    - watch:
      - sls: {{ sls_config_file }}

    {%- endfor %}
