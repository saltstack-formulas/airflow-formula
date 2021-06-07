# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as a with context %}
{%- set sls_archive_clean = tplroot ~ '.archive.clean' %}
{%- set sls_package_clean = tplroot ~ '.package.clean' %}

include:
  - {{ sls_archive_clean if a.pkg.airflow.use_upstream|lower == 'archive' else sls_package_clean }}

    {%- for name in a.service.airflow.enabled %}

airflow-service-clean-{{ name }}:
  service.dead:
    - name: {{ name }}
    - enable: False
    - require_in:
      - sls: {{ sls_archive_clean if a.pkg.airflow.use_upstream|lower == 'archive' else sls_package_clean }}
        {%- if grains.kernel|lower == 'linux' %}
    - onlyif: systemctl list-units | grep {{ name }} >/dev/null 2>&1
  file.absent:
    - name: {{ a.dir.airflow.service }}{{ a.div }}{{ name }}.service
    - require:
      - service: airflow-service-clean-{{ name }}
  cmd.run:
    - onlyif: {{ grains.kernel|lower == 'linux' }}
    - name: systemctl daemon-reload
    - require:
      - file: airflow-service-clean-{{ name }}

        {%- endif %}
    {%- endfor %}
