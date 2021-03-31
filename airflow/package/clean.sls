# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as d with context %}
{%- set sls_service_clean = tplroot ~ '.service.clean' %}

include:
  - {{ sls_service_clean }}

airflow-package-clean-pip:
  pip.removed:
        {%- if d.pkg.airflow.extras is iterable %}
    - name: {{ d.pkg.airflow.name }} {{ d.pkg.airflow.extras|list|replace("'","") }}
        {%- else %}
    - name: {{ d.pkg.airflow.name }}
        {%- endif %}
    - user: {{ d.identity.airflow.user }}
    - require:
      - sls: {{ sls_service_clean }}
  file.absent:
    - name: {{ d.dir.airflow.virtualenv }}
