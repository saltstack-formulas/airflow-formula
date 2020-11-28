# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- set sls_archive_clean = tplroot ~ '.archive.clean' %}
{%- set sls_package_clean = tplroot ~ '.package.clean' %}

include:
  - {{ sls_archive_clean if d.pkg.airflow.use_upstream|lower == 'archive' else sls_package_clean }}

    {%- for name in d.service.airflow.enabled %}

airflow-service-clean-{{ name }}:
  service.dead:
    - name: {{ name }}
    - enable: False
    - require_in:
      - sls: {{ sls_archive_clean if d.pkg.airflow.use_upstream|lower == 'archive' else sls_package_clean }}
        {%- if grains.kernel|lower == 'linux' %}
    - onlyif: systemctl list-units | grep {{ name }} >/dev/null 2>&1
  file.absent:
    - name: {{ d.dir.airflow.service }}{{ d.div }}{{ name }}.service
    - require:
      - service: airflow-service-clean-{{ name }}
  cmd.run:
    - onlyif: {{ grains.kernel|lower == 'linux' }}
    - name: systemctl daemon-reload
    - require:
      - file: airflow-service-clean-{{ name }}

        {%- endif %}
    {%- endfor %}
