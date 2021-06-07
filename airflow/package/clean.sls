# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import airflow as a with context %}
{%- set sls_service_clean = tplroot ~ '.service.clean' %}

include:
  - {{ sls_service_clean }}

airflow-package-clean-pip:
  pip.removed:
        {%- if a.pkg.airflow.extras is iterable %}
    - name: {{ a.pkg.airflow.name }} {{ a.pkg.airflow.extras|list|replace("'","") }}
        {%- else %}
    - name: {{ a.pkg.airflow.name }}
        {%- endif %}
    - user: {{ a.identity.airflow.user }}
    - require:
      - sls: {{ sls_service_clean }}
  file.absent:
    - name: {{ a.dir.airflow.virtualenv }}
